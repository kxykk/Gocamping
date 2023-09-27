# routes.py
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from api.text.text_schema import TextCreate, TextUpdate
from api.text.text_crud import get_text, create_text, update_text, delete_text
from api.server_response.server_response_model import ServerResponse
import database

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

router = APIRouter()

@router.post("/", response_model=ServerResponse)
async def create_text_route(text: TextCreate, db: Session = Depends(get_db)):
    db_text = create_text(db, text)
    return {"success": True, "text": db_text}

@router.get("/{text_id}", response_model=ServerResponse)
async def read_text(text_id: int, db: Session = Depends(get_db)):
    db_text = get_text(db, text_id)
    if db_text is None:
        raise HTTPException(status_code=404, detail="Text not found")
    return {"success": True, "text": db_text}

@router.put("/{text_id}", response_model=ServerResponse)
async def update_text_route(text_id: int, text: TextUpdate, db: Session = Depends(get_db)):
    updated_text = update_text(db, text_id, text)
    if not updated_text:
        raise HTTPException(status_code=404, detail="Text not found")
    return {"success": True, "text": updated_text}

@router.delete("/{text_id}", response_model=ServerResponse)
async def delete_text_route(text_id: int, db: Session = Depends(get_db)):
    db_text = delete_text(db, text_id)
    if not db_text:
        raise HTTPException(status_code=404, detail="Text not found")
    return {"success": True, "message": "Text successfully deleted"}

