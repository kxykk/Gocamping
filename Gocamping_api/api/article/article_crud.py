# article_crud.py
from typing import List
from sqlalchemy.orm import Session
from .article_model import ArticleModel
from .article_schema import ArticleCreate, ArticleUpdate
from api.image.image_model import ImageModel
from api.text.text_model import TextModel
from api.comment.comment_model import CommentModel
from datetime import date

def create_article(db: Session, article: ArticleCreate):
    article_dict = article.dict()
    article_dict["article_createDate"] = date.today()
    db_article = ArticleModel(**article_dict)
    db.add(db_article)
    db.commit()
    db.refresh(db_article)
    return db_article  

def get_all_article_ids_and_titles(db: Session):
    return db.query(ArticleModel.article_id, ArticleModel.article_title).all()

def get_by_user_id(db: Session, user_id: int):
    return db.query(ArticleModel.article_id, ArticleModel.article_title).filter(ArticleModel.user_id == user_id).all()

def get_article_details(db: Session, article_id: int):
    images = db.query(ImageModel).filter(ImageModel.article_id == article_id).order_by(ImageModel.image_sortNumber).all()
    texts = db.query(TextModel).filter(TextModel.article_id == article_id).order_by(TextModel.text_sortNumber).all()

    # 將text跟image放在同一個陣列中
    combined_list = []
    for image in images:
        if image.image_type == "content":
            combined_list.append(("image", image, image.image_sortNumber))
    for text in texts:
        combined_list.append(("text", text , text.text_sortNumber))

    # Sort
    sorted_list = sorted(combined_list, key=lambda item: item[2])

    return sorted_list

def delete_article_content(db: Session, article_id: int):
    # 檢查文章是否存在
    db_article = db.query(ArticleModel).filter(ArticleModel.article_id == article_id).first()
    if db_article is None:
        return None
    
    # 刪除文字和圖片，並紀錄刪除的數量
    deleted_texts_count = db.query(TextModel).filter(TextModel.article_id == article_id).delete()
    deleted_images_count = db.query(ImageModel).filter(
        ImageModel.article_id == article_id,
        ImageModel.image_type == "content").delete()
    db.commit()
    
    # 判斷是否有進行刪除操作
    if deleted_texts_count > 0 or deleted_images_count > 0:
        return True  # 有內容被刪除
    else:
        return False  # 沒有內容被刪除


# Delete with comments
def delete_article(db: Session, article_id: int):
    db_article = db.query(ArticleModel).filter(ArticleModel.article_id == article_id).first()
    if db_article is None:
        return None
    images = db.query(ImageModel).filter(ImageModel.article_id == article_id).delete()
    texts = db.query(TextModel).filter(TextModel.article_id == article_id).delete()
    comments = db.query(CommentModel).filter(CommentModel.article_id == article_id).delete()
    db.delete(db_article)
    db.commit()

    return db_article

def update_article(db: Session, article: ArticleUpdate):
    db_article = db.query(ArticleModel).filter(ArticleModel.article_id == article.article_id).first()
    if db_article is None:
        return None
    for var, value in vars(article).items():
        setattr(db_article, var, value) if value else None
    db.add(db_article)
    db.commit()
    db.refresh(db_article)
    return db_article

def search_articles(db: Session, keyword: str):
    return db.query(ArticleModel.article_id, ArticleModel.article_title)\
             .filter(ArticleModel.article_title.ilike(f"%{keyword}%"))\
             .all()

