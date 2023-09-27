from sqlalchemy import or_
from sqlalchemy.orm import Session
from .camp_model import CampModel
from .camp_schema import CampCreate, CampUpdate

def get_camp(db: Session, camp_id: int):
    db_camp = db.query(CampModel).filter(CampModel.camp_id == camp_id).first()
    if db_camp:
        return db_camp.__dict__
    return None

def get_camps(db: Session, skip: int = 0, limit: int = 100):
    camps = db.query(CampModel).offset(skip).limit(limit).all()
    return [camp.__dict__ for camp in camps]


def create_camp(db: Session, camp: CampCreate):
    db_camp = CampModel(**camp.dict())
    db.add(db_camp)
    db.commit()
    db.refresh(db_camp)
    return db_camp

def update_camp(db: Session, camp: CampUpdate):
    db_camp = db.query(CampModel).filter(CampModel.camp_id == camp.camp_id).first()
    if db_camp is None:
        return None
    for var, value in vars(camp).items():
        setattr(db_camp, var, value) if value else None
    db.add(db_camp)
    db.commit()
    db.refresh(db_camp)
    return db_camp

def delete_camp(db: Session, camp_id: int):
    db_camp = db.query(CampModel).filter(CampModel.camp_id == camp_id).first()
    if db_camp is None:
        return None
    db.delete(db_camp)
    db.commit()
    return db_camp

def search_camps(db:Session, keyword: str):
    query_results = db.query(CampModel).filter(
        or_(
            CampModel.camp_name.ilike(f"%{keyword}%"),
            CampModel.camp_city.ilike(f"%{keyword}%"),
            CampModel.camp_location.ilike(f"%{keyword}%")
        )
    ).all()
    return [result.__dict__ for result in query_results]