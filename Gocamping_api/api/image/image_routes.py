from fastapi import APIRouter, HTTPException, Depends, Form
from sqlalchemy.orm import Session
from api.image.image_schema import ImageCreate, ImageUpdate, ImageType, Image
from api.image.image_crud import get_image, create_image, update_image, delete_image, get_image_by_article_and_type, get_images_by_user_id, get_images_by_camp_id
from api.camp.camp_crud import fetch_camp_name_from_db
from api.server_response.server_response_model import ServerResponse
from fastapi import UploadFile, File
from pathlib import Path
from fastapi import UploadFile
import shutil
from io import BytesIO
import uuid
import os
import database
import requests

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

router = APIRouter()

@router.post("/", response_model=ServerResponse)
async def create_image_route(image: ImageCreate, db: Session = Depends(get_db)):
    if not (image.article_id or image.user_id):  
        return ServerResponse(success=False, errorCode="MissingID")
    db_image = create_image(db, image)
    if db_image:
        return ServerResponse(success=True, image=db_image)
    else:
        return ServerResponse(success=False, errorCode="ImageCreationFailed")



@router.put("/{image_id}", response_model=ServerResponse)
async def update_image_route(image_id: int, image: ImageUpdate, db: Session = Depends(get_db)):
    updated_image = update_image(db, image_id, image)
    if updated_image:
        return ServerResponse(success=True, image=updated_image)
    else:
        raise HTTPException(status_code=404, detail="Image not found")



@router.delete("/{image_id}", response_model=ServerResponse)
async def delete_image_route(image_id: int, db: Session = Depends(get_db)):
    db_image = delete_image(db, image_id)
    if db_image:
        return ServerResponse(success=True, detail="Image deleted")
    else:
        raise HTTPException(status_code=404, detail="Image not found")
    
@router.get("/image/{image_id}", response_model=ServerResponse)
async def read_image(image_id: int, db: Session = Depends(get_db)):
    db_image = get_image(db, image_id)
    if db_image:
        return ServerResponse(success=True, image=db_image)
    else:
        raise HTTPException(status_code=404, detail="Image not found")

@router.get("/get/", response_model=ServerResponse)
async def get_image_info(article_id: int, image_type: ImageType, db: Session = Depends(get_db)): 
    db_image = get_image_by_article_and_type(db, article_id, image_type.value) 

    if db_image:
        return ServerResponse(success=True, image=db_image)
    else:
        return ServerResponse(success=False, errorCode="ImageNotFound")

@router.get("/get_by_user/{user_id}", response_model=ServerResponse)
async def get_images_by_user_id_route(user_id: int, db: Session = Depends(get_db)):
    db_images = get_images_by_user_id(db, user_id)
    if db_images:
        return ServerResponse(success=True, image=db_images[0])
    else:
        return ServerResponse(success=False, errorCode="ImagesNotFound")

@router.get("/get_by_camp/{camp_id}", response_model=ServerResponse)
async def get_images_by_camp_id_route(camp_id: int, db: Session = Depends(get_db)):
    db_images = get_images_by_camp_id(db, camp_id)
    if db_images:
        return ServerResponse(success=True, image=db_images[0])
    else:
        camp_name = fetch_camp_name_from_db(camp_id, db)
        if not camp_name:
            raise HTTPException(status_code=409, detail="Camp not found")
        
        server_response = await get_google_place_image(camp_id, camp_name, db)
        if server_response.success:
            return server_response
        else:
            raise HTTPException(status_code=409, detail="Images not found for the given camp ID")

@router.get("/get_google_place_image/", response_model=ServerResponse)
async def get_google_place_image(camp_id: int, camp_name: str, db: Session = Depends(get_db)):
    google_places_api_key = "AIzaSyBhcbPpww75eRWWoE_JylkQ7bvHcsd_PMk"
    place_search_url = f"https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input={camp_name}&inputtype=textquery&fields=photos&key={google_places_api_key}"
    
    response = requests.get(place_search_url)
    if response.status_code == 200:
        json_data = response.json()
        photo_reference = json_data["candidates"][0]["photos"][0]["photo_reference"]
        photo_url = f"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference={photo_reference}&key={google_places_api_key}"
        
        image_response = requests.get(photo_url)
        if image_response.status_code == 200:
            image_data = image_response.content
            file_uuid = uuid.uuid4().hex

            image_file = UploadFile(
               filename=f"{file_uuid}.jpg",
               file=BytesIO(image_data)
            )
            upload_response = await upload_file(
                file=image_file,
                article_id=None,
                user_id=None,
                camp_id=camp_id,
                image_sortNumber=0,
                image_type="camp", 
                db=db
            )
            return upload_response
    return ServerResponse(success=False, errorCode="ImageNotFound")





@router.post("/upload/", response_model=ServerResponse)
async def upload_file(
        file: UploadFile = File(...),
        article_id: int = Form(None),  
        user_id: int = Form(None),  
        camp_id: int = Form(None),
        image_sortNumber: int = Form(0),
        image_type: str = Form(...), 
        db: Session = Depends(get_db)):
    
    if not (article_id or user_id or camp_id):  
        return ServerResponse(success=False, errorCode="MissingID")
    
    base_path = Path("./pictures/") 
    base_path.mkdir(parents=True, exist_ok=True)
    save_path = base_path / file.filename
    with save_path.open("wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    file_size = save_path.stat().st_size
    print("Saving to:", save_path)
    image_data = ImageCreate(
        article_id=article_id, 
        user_id=user_id,
        camp_id=camp_id,
        image_sortNumber=image_sortNumber,
        imageURL=file.filename,  
        image_format=file.filename.split('.')[-1],
        image_size=file_size,
        image_type=image_type 
    )

    if camp_id and image_type == "camp":  
        existing_images = get_images_by_camp_id(db, camp_id)  
        if existing_images:
            # Update existing image
            updated_image = update_image(db, existing_images[0].image_id, image_data)
            if updated_image:
                return ServerResponse(success=True, image=updated_image)
            else:
                return ServerResponse(success=False, errorCode="ImageUpdateFailed")
        else:
            # Create new image if none exists
            print("Image Data:", image_data)
            db_image = create_image(db, image_data)
            print("Saving to:", save_path)
            print("DB Image:", db_image)
            print("Creating image with data:", image_data)
            if db_image:
                return ServerResponse(success=True, image=db_image)
            else:
                return ServerResponse(success=False, errorCode="ImageCreationFailed")
            
    elif user_id and image_type == "user":
        existing_images = get_images_by_user_id(db, user_id)
        if existing_images:
            # Update existing image
            updated_image = update_image(db, existing_images[0].image_id, image_data)
            if updated_image:
                return ServerResponse(success=True, image=updated_image)
            else:
                return ServerResponse(success=False, errorCode="ImageUpdateFailed")
        else:
            # Create new image if none exists
            db_image = create_image(db, image_data)
            if db_image:
                return ServerResponse(success=True, image=db_image)
            else:
                return ServerResponse(success=False, errorCode="ImageCreationFailed")
    else:
        # Create new image for non-user types or if user_id is not provided
        db_image = create_image(db, image_data)
        if db_image:
            return ServerResponse(success=True, image=db_image)
        else:
            return ServerResponse(success=False, errorCode="ImageCreationFailed")



