# article_collection_crud.py
from sqlalchemy.orm import Session
from typing import List
from .article_collection_model import ArticleCollectionModel
from .article_collection_schema import ArticleCollectionCreate
from api.article.article_model import ArticleModel

def create_article_collection(db: Session, article_collection: ArticleCollectionCreate):
    db_article_collection = ArticleCollectionModel(**article_collection.dict())
    db.add(db_article_collection)
    db.commit()
    db.refresh(db_article_collection)
    return db_article_collection

def get_all_article_ids_by_user_id(db: Session, user_id: int):
    result = db.query(ArticleCollectionModel.article_id, ArticleModel.article_title).filter(
        ArticleCollectionModel.user_id == user_id
    ).join(ArticleModel, ArticleModel.article_id == ArticleCollectionModel.article_id).all()

    return [{"article_id": x[0], "article_title": x[1]} for x in result]

def get_article_collection_by_ids(db: Session, user_id: int, article_id: int):
    return db.query(ArticleCollectionModel).filter(
        (ArticleCollectionModel.user_id == user_id) & 
        (ArticleCollectionModel.article_id == article_id)
    ).first()

def delete_article_collection(db: Session, user_id: int, article_id: int):
    db_article_collection = db.query(ArticleCollectionModel).filter(
        (ArticleCollectionModel.user_id == user_id) & 
        (ArticleCollectionModel.article_id == article_id)
    ).first()
    if db_article_collection is None:
        return None
    db.delete(db_article_collection)
    db.commit()
    return {"message": "Article Collection successfully deleted"}
