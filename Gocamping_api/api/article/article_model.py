# articleModel.py

from sqlalchemy import Column, Integer, String, Date, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class ArticleModel(Base):
    __tablename__ = "article"

    article_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("user.user_id"))
    article_createDate = Column(Date)
    article_title = Column(String)

    owner = relationship("UserModel", back_populates="articles")
    texts = relationship("TextModel", back_populates="article", cascade="all, delete-orphan")
    images = relationship("ImageModel", back_populates="article", cascade="all, delete-orphan")
    comments = relationship("CommentModel", back_populates="article", cascade="all, delete-orphan")
    collected_by = relationship("UserModel", secondary="article_collections", back_populates="collections")