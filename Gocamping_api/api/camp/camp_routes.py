from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from .camp_crud import get_camp, create_camp, update_camp, delete_camp, get_camps,search_camps
from .camp_schema import Camp, CampCreate, CampUpdate
from typing import List
import database 
from api.server_response.server_response_model import ServerResponse

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

router = APIRouter()

@router.get("/", response_model=ServerResponse)
async def read_camps(skip: int = 0, limit: int = 2000, db: Session = Depends(get_db)):
    camps = get_camps(db, skip=skip, limit=limit)
    return ServerResponse(success=True, camps=camps)

@router.post("/", response_model=ServerResponse)
async def create_a_camp(camp: CampCreate, db: Session = Depends(get_db)):
    return ServerResponse(success=True, camp=create_camp(db, camp))

@router.get("/{camp_id}", response_model=ServerResponse)
async def read_a_camp(camp_id: int, db: Session = Depends(get_db)):
    db_camp = get_camp(db, camp_id)
    if db_camp is None:
        raise HTTPException(status_code=404, detail="Camp not found")
    return ServerResponse(success=True, camp=db_camp)

@router.put("/{camp_id}", response_model=ServerResponse)
async def update_a_camp(camp_id: int, camp: CampUpdate, db: Session = Depends(get_db)):
    updated_camp = update_camp(db, camp)
    if updated_camp is None:
        raise HTTPException(status_code=404, detail="Camp not found or failed to update")
    return ServerResponse(success=True, camp=updated_camp)

@router.delete("/{camp_id}")
async def delete_a_camp(camp_id: int, db: Session = Depends(get_db)):
    db_camp = delete_camp(db, camp_id)
    if db_camp is None:
        raise HTTPException(status_code=404, detail="Camp not found")
    return ServerResponse(success=True, message="Camp successfully deleted")

@router.get("/search/", response_model=ServerResponse)
async def search_camps_route(keyword: str, db:Session = Depends(get_db)):
    results = search_camps(db, keyword)
    if not results:
        raise HTTPException(status_code=404, detail="No camps found for the given keyword")
    return ServerResponse(success=True, camps=results)