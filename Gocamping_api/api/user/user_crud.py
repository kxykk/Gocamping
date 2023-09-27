from sqlalchemy.orm import Session
from .user_model import UserModel
from api.article.article_model import ArticleModel
from .user_schema import UserCreate
from datetime import datetime
import bcrypt
from sqlalchemy import or_

def create_user(db: Session, user: UserCreate):
    user_dict = user.dict()
    hashed_password = bcrypt.hashpw(user_dict["password"].encode('utf-8'), bcrypt.gensalt())
    user_dict["password"] = hashed_password.decode('utf-8')
    user_dict["account_createDate"] = datetime.utcnow()
    db_user = UserModel(**user_dict)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def update_user(db: Session, user_id: int, user_data: dict):
    db_user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
    if db_user is None:
        return None
    if "password" in user_data:
        hashed_password = bcrypt.hashpw(user_data["password"].encode('utf-8'), bcrypt.gensalt())
        user_data["password"] = hashed_password.decode('utf-8')
    for key, value in user_data.items():
        if hasattr(db_user, key) and value is not None:
            setattr(db_user, key, value)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def delete_user(db: Session, user_id: int):
    db_user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
    if db_user is None:
        return None
    db.delete(db_user)
    db.commit()
    return db_user

def get_user(db: Session, user_id: int):
    return db.query(UserModel).filter(UserModel.user_id == user_id).first()

def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(UserModel).offset(skip).limit(limit).all()


def search_users(db: Session, email: str):
    return db.query(UserModel).filter(UserModel.email == email).first()



def get_user_by_article(db: Session, article_id: int):
    return db.query(UserModel).join(ArticleModel, ArticleModel.user_id == UserModel.user_id).filter(ArticleModel.article_id == article_id).first()

def update_user_introduction(db: Session, user_id: int, introduction: str):
    db_user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
    if db_user is None:
        return None
    db_user.introduction = introduction
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
