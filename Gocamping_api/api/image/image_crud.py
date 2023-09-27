# image_crud.py
from sqlalchemy.orm import Session
from .image_model import ImageModel
from .image_schema import ImageCreate, ImageUpdate

def get_image(db: Session, image_id: int):
    return db.query(ImageModel).filter(ImageModel.image_id == image_id).first()

def get_images(db: Session, skip: int = 0, limit: int = 100):
    return db.query(ImageModel).offset(skip).limit(limit).all()


def get_image_by_article_and_type(db: Session, article_id: int, image_type: str):
    return db.query(ImageModel).filter(
        ImageModel.article_id == article_id,
        ImageModel.image_type == image_type
    ).first()

def get_images_by_camp_id(db: Session, camp_id: int):
    return db.query(ImageModel).filter(
        ImageModel.camp_id == camp_id
    ).all()

def get_images_by_user_id(db: Session, user_id: int):
    return db.query(ImageModel).filter(
        ImageModel.user_id == user_id
    ).all()

def create_image(db: Session, image: ImageCreate):
    if not (image.article_id or image.user_id):
        return None
    db_image = ImageModel(**image.dict())
    db.add(db_image)
    db.commit()
    db.refresh(db_image)
    return db_image

def update_image(db: Session, image_id: int, image: ImageUpdate):
    db_image = db.query(ImageModel).filter(ImageModel.image_id == image_id).first()
    if db_image is None:
        return None
    for var, value in vars(image).items():
        setattr(db_image, var, value) if value else None
    db.add(db_image)
    db.commit()
    db.refresh(db_image)
    return db_image

def delete_image(db: Session, image_id: int):
    db_image = db.query(ImageModel).filter(ImageModel.image_id == image_id).first()
    if db_image is None:
        return None
    db.delete(db_image)
    db.commit()
    return db_image
