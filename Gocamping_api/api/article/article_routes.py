# article.routes.py
from fastapi import HTTPException, APIRouter, Depends
from sqlalchemy.orm import Session
from .article_crud import create_article, update_article, delete_article, get_all_article_ids_and_titles, get_by_user_id, get_article_details, delete_article_content, search_articles
from .article_schema import Article, ArticleCreate, ArticleUpdate, ArticleIdAndTitle
from database import SessionLocal
from api.server_response.server_response_model import ServerResponse, CombinedItem
from typing import List

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


router = APIRouter()

@router.post("/", response_model=ServerResponse)
async def create_article_route(article: ArticleCreate, db: Session = Depends(get_db)):
    created_article = create_article(db, article)
    if created_article:
        response_article = Article(**created_article.__dict__)
        return ServerResponse(success=True, article=response_article)
    else:
        raise HTTPException(status_code=400, detail="Article creation failed")
    
@router.get("/search/",response_model=ServerResponse)
async def search_articles_route(keyword: str, db: Session = Depends(get_db)):
    results = search_articles(db, keyword)
    if not results: 
        raise HTTPException(status_code=404, detail="No articles found for the given keyword")
    articles = [ArticleIdAndTitle(article_id=result[0], article_title=result[1]) for result in results]
    return ServerResponse(success=True, articles=articles)

    
@router.get("/all_ids_and_titles/", response_model=ServerResponse)
async def get_all_article_ids_and_titles_route(db: Session = Depends(get_db)):
    results = get_all_article_ids_and_titles(db)
    articles = [ArticleIdAndTitle(article_id=result[0], article_title=result[1]) for result in results]
    return ServerResponse(success=True, articles=articles) 

@router.get("/by_user_id/", response_model=ServerResponse)
async def get_by_user_id_route(user_id: int, db: Session = Depends(get_db)):
    results = get_by_user_id(db, user_id)
    articles = [ArticleIdAndTitle(article_id=result[0], article_title=result[1]) for result in results]
    return ServerResponse(success=True, articles=articles)

@router.get("/details/{article_id}", response_model=ServerResponse)
async def get_article_details_route(article_id: int, db: Session = Depends(get_db)):
    sorted_list = get_article_details(db, article_id)
    combinedItems = [CombinedItem(type=item[0], item=item[1], sortNumber=item[2]) for item in sorted_list]
    return ServerResponse(success=True, combinedItems=combinedItems)







@router.put("/{article_id}", response_model=Article)
async def update_article_route(article_id: int, article: ArticleUpdate, db: Session = Depends(get_db)):
    db_article = update_article(db, article_id, article)
    if db_article:
        return ServerResponse(success=True, detail="Article updated successfully")
    else:
        raise HTTPException(status_code=404, detail="Article not found")
    
@router.delete("/delete_content/{article_id}", response_model=ServerResponse)
async def delete_article_content_route(article_id: int, db: Session = Depends(get_db)):
    result = delete_article_content(db, article_id)
    if result is None:
        raise HTTPException(status_code=404, detail="Article not found")
    elif result:
        return ServerResponse(success=True, detail="Article content deleted successfully")
    else:
        return ServerResponse(success=True, detail="No content to delete")



@router.delete("/{article_id}", response_model=ServerResponse)
async def delete_article_route(article_id: int, db: Session = Depends(get_db)):
    db_article = delete_article(db, article_id)
    if db_article:
        return ServerResponse(success=True, detail="Article deleted")
    else:
        raise HTTPException(status_code=404, detail="Article not found")
    

