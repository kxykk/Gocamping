# text_crud.py
from sqlalchemy.orm import Session
from .text_model import TextModel
from .text_schema import TextCreate, TextUpdate

def get_text(db: Session, text_id: int):
    return db.query(TextModel).filter(TextModel.text_id == text_id).first()

def get_texts(db: Session, skip: int = 0, limit: int = 100):
    return db.query(TextModel).offset(skip).limit(limit).all()

def create_text(db: Session, text: TextCreate):
    db_text = TextModel(**text.dict())
    db.add(db_text)
    db.commit()
    db.refresh(db_text)
    return db_text

def update_text(db: Session, text_id: int, text: TextUpdate):
    db_text = db.query(TextModel).filter(TextModel.text_id == text_id).first()
    if db_text is None:
        return None
    for var, value in vars(text).items():
        setattr(db_text, var, value) if value else None
    db.add(db_text)
    db.commit()
    db.refresh(db_text)
    return db_text

def delete_text(db: Session, text_id: int):
    db_text = db.query(TextModel).filter(TextModel.text_id == text_id).first()
    if db_text is None:
        return None
    db.delete(db_text)
    db.commit()
    return db_text
