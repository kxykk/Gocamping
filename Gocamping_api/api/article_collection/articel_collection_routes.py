# routes.py
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from api.article_collection.article_collection_model import ArticleCollectionModel
from api.article_collection.article_collection_schema import ArticleCollectionCreate, ArticleCollections
from api.article_collection.article_collection_crud import get_all_article_ids_by_user_id
from api.server_response.server_response_model import ServerResponse
import database 


def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

router = APIRouter()


@router.post("/", response_model=ArticleCollections)
async def create_article_collection(article_collection: ArticleCollectionCreate, db: Session = Depends(get_db)):
    # 檢查是否已經收藏過
    existing_article_collection = db.query(ArticleCollectionModel).filter(
        (ArticleCollectionModel.article_id == article_collection.article_id) &
        (ArticleCollectionModel.user_id == article_collection.user_id)
    ).first()
    if existing_article_collection:
        raise HTTPException(status_code=409, detail="Article Collection already exist")
    # 如果沒有，則新增
    db_article_collection = ArticleCollectionModel(**article_collection.dict())
    db.add(db_article_collection)
    db.commit()
    db.refresh(db_article_collection)
    return db_article_collection

@router.get("/articles_by_userid/{user_id}", response_model=ServerResponse)
async def read_all_article_ids_by_user_id(user_id: int, db: Session = Depends(get_db)):
    article_dicts = get_all_article_ids_by_user_id(db, user_id)

    if not article_dicts:
        raise HTTPException(status_code=404, detail="No articles found for this user")

    response = ServerResponse(
        success=True,
        articles=article_dicts
    )
    return response




@router.delete("/{article_id}/{user_id}")
async def delete_article_collection(article_id: int, user_id: int, db: Session = Depends(get_db)):
    db_article_collection = db.query(ArticleCollectionModel).filter(
        (ArticleCollectionModel.article_id == article_id) & (ArticleCollectionModel.user_id == user_id)
    ).first()
    if db_article_collection is None:
        raise HTTPException(status_code=404, detail="Article Collection not found")
    db.delete(db_article_collection)
    db.commit()
    return {"message": "Article Collection successfully deleted"}
