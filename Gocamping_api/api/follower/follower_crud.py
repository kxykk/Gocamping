# follower_crud.py
from sqlalchemy.orm import Session
from .follower_model import FollowerModel

def create_follower(db: Session, user_id: int, follower_id: int):
    db_follower = FollowerModel(user_id=user_id, follower_id=follower_id)
    db.add(db_follower)
    db.commit()
    db.refresh(db_follower)
    return db_follower

def get_followers_of_user(db: Session, user_id: int):
    return db.query(FollowerModel).filter(FollowerModel.user_id == user_id).all()

def delete_follower(db: Session, user_id: int, follower_id: int):
    db_follower = db.query(FollowerModel).filter(
        FollowerModel.user_id == user_id,
        FollowerModel.follower_id == follower_id
    ).first()
    if db_follower is None:
        return None
    db.delete(db_follower)
    db.commit()
    return db_follower
