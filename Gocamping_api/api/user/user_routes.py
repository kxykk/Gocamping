# user.routes.py
from fastapi import HTTPException, APIRouter, Depends, Body
from sqlalchemy.orm import Session
from sqlalchemy import exists
from api.user.user_schema import UserCreate, UserUpdate
from api.user.user_model import UserModel
from .user_crud import get_user, create_user, update_user, delete_user,get_user_by_article, update_user_introduction, search_users
import database 
import bcrypt
from api.server_response.server_response_model import ServerResponse

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

router = APIRouter()

def is_email_exist(db: Session, email: str):
    return db.query(exists().where(UserModel.email == email)).scalar()


@router.post("/", response_model=ServerResponse)
async def create_user_route(user: UserCreate, db: Session = Depends(get_db)):

    if is_email_exist(db, user.email):
        raise HTTPException(status_code=409, detail="Email has already been exists")

    created_user = create_user(db, user)
    if created_user:
        return ServerResponse(success=True, user=created_user)
    else:
        raise HTTPException(status_code=400, detail="User creation failed")
    
@router.post("/login/", response_model=ServerResponse)
async def login_user_route(email: str = Body(...), password: str = Body(...), db: Session = Depends(get_db)):    
    db_user = db.query(UserModel).filter(UserModel.email == email).first()
    if db_user is None:
        raise HTTPException(status_code=404, detail="Email not found") 
    if bcrypt.checkpw(password.encode('utf-8'), db_user.password.encode('utf-8')):
        return ServerResponse(success=True, user=db_user)
    else:     
        raise HTTPException(status_code=401, detail="Password is incorrect")


@router.get("/{user_id}", response_model=ServerResponse)
async def read_user(user_id: int, db: Session = Depends(get_db)):
    db_user = get_user(db, user_id)
    if db_user:
        return ServerResponse(success=True, user=db_user)
    else:
        raise HTTPException(status_code=404, detail="User not found")
    
@router.get("/by_article/{article_id}", response_model=ServerResponse)
async def get_user_by_article_route(article_id: int, db: Session = Depends(get_db)): 
    db_user = get_user_by_article(db, article_id)

    if db_user:
        return ServerResponse(success=True, user=db_user)
    else:
        return ServerResponse(success=False, errorCode="UserNotFound")



@router.put("/{user_id}", response_model=ServerResponse)
async def update_user_route(user_id: int, user: UserUpdate, db: Session = Depends(get_db)):
    db_user = update_user(db, user_id, user)
    if db_user:
        return ServerResponse(success=True, user=db_user)
    else:
        raise HTTPException(status_code=404, detail="User not found")
    
@router.put("/introduction/{user_id}", response_model=ServerResponse)
async def update_user_introduction_route(user_id: int, user_update: UserUpdate, db: Session = Depends(get_db)):
    db_user = update_user_introduction(db, user_id, user_update.introduction)
    if db_user:
        return ServerResponse(success=True, user=db_user)
    else:
        raise HTTPException(status_code=404, detail="User not found")

@router.get("/search/", response_model=ServerResponse)
async def search_users_route(email: str, db: Session = Depends(get_db)):
    db_user = search_users(db, email)
    if db_user:
        return ServerResponse(success=True, user=db_user)
    else:
        return ServerResponse(success=False, errorCode="UserNotFound")


@router.delete("/{user_id}", response_model=ServerResponse)
async def delete_user_route(user_id: int, db: Session = Depends(get_db)):
    db_user = delete_user(db, user_id)
    if db_user:
        return ServerResponse(success=True, detail="User deleted")
    else:
        raise HTTPException(status_code=404, detail="User not found")
    

