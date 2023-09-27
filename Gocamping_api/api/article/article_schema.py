# article_schemas.py

from typing import Optional
from pydantic import BaseModel
from datetime import date

class ArticleBase(BaseModel):
    user_id: int
    article_createDate: date
    article_title: str
   

class ArticleCreate(ArticleBase):
    pass

class Article(ArticleBase):
    article_id: int

class ArticleIdAndTitle(BaseModel):
    article_id: int
    article_title: str


class ArticleUpdate(BaseModel):
    title: Optional[str] = None

    class Config:
        from_attributes = True
