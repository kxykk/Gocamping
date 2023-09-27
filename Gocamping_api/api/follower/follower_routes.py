# follower_routes.py
from typing import List
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from api.follower.follower_schema import Follower, FollowerCreate
from api.follower.follower_crud import create_follower, get_followers_of_user, delete_follower
import database 

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

router = APIRouter()

@router.post("/", response_model=Follower)
async def create_follower_route(follower: FollowerCreate, db: Session = Depends(get_db)):
    return create_follower(db, follower.user_id, follower.follower_id)

@router.get("/user/{user_id}", response_model=List[Follower])
async def get_followers_of_user_route(user_id: int, db: Session = Depends(get_db)):
    return get_followers_of_user(db, user_id)

@router.delete("/")
async def delete_follower_route(follower: FollowerCreate, db: Session = Depends(get_db)):
    deleted_follower = delete_follower(db, follower.user_id, follower.follower_id)
    if not deleted_follower:
        raise HTTPException(status_code=404, detail="Follower relationship not found")
    return {"detail": "Follower relationship deleted"}
