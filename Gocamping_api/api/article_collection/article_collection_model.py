# articleCollectionModel.py
from sqlalchemy import Column, Integer, ForeignKey
from database import Base

class ArticleCollectionModel(Base):
    __tablename__ = "article_collections"

    user_id = Column(Integer, ForeignKey("user.user_id"), primary_key=True)
    article_id = Column(Integer, ForeignKey("article.article_id"), primary_key=True)
