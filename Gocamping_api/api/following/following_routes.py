# following_routes.py
from typing import List
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from api.following.following_schema import Following, FollowingCreate
from api.following.following_crud import create_following, get_following_by_user_id, delete_following
import database 

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

router = APIRouter()

@router.post("/", response_model=Following)
async def create_following_route(following: FollowingCreate, db: Session = Depends(get_db)):
    return create_following(db, following.user_id, following.following_id)

@router.get("/user/{user_id}", response_model=List[Following])
async def get_followings_of_user(user_id: int, db: Session = Depends(get_db)):
    return get_following_by_user_id(db, user_id)

@router.delete("/")
async def delete_following_route(following: FollowingCreate, db: Session = Depends(get_db)):
    deleted_following = delete_following(db, following.user_id, following.following_id)
    if not deleted_following:
        raise HTTPException(status_code=404, detail="Following relationship not found")
    return {"detail": "Following deleted"}
