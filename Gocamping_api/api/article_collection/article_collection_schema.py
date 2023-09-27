#article_collection_schemas.py
from pydantic import BaseModel

class ArticleCollectionBase(BaseModel):
    user_id: int
    article_id: int

class ArticleCollectionCreate(ArticleCollectionBase):
    pass

class ArticleCollections(ArticleCollectionBase):
    class Config:
        from_attributes = True
