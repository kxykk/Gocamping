# following_crud.py
from sqlalchemy.orm import Session
from .following_model import FollowingModel

def create_following(db: Session, user_id: int, following_id: int):
    db_following = FollowingModel(user_id=user_id, following_id=following_id)
    db.add(db_following)
    db.commit()
    db.refresh(db_following)
    return db_following

def get_following_by_user_id(db: Session, user_id: int):
    return db.query(FollowingModel).filter(FollowingModel.user_id == user_id).all()

def get_followers_by_following_id(db: Session, following_id: int):
    return db.query(FollowingModel).filter(FollowingModel.following_id == following_id).all()

def delete_following(db: Session, user_id: int, following_id: int):
    db_following = db.query(FollowingModel).filter(
        FollowingModel.user_id == user_id, 
        FollowingModel.following_id == following_id
    ).first()
    if db_following is None:
        return None
    db.delete(db_following)
    db.commit()
    return db_following
