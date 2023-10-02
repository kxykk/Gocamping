# userModel.py
from sqlalchemy import Column, Integer, String, Date
from sqlalchemy.orm import relationship
from database import Base

from api.follower.follower_model import FollowerModel
from api.following.following_model import FollowingModel

class UserModel(Base):
    __tablename__ = "user"

    user_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    email = Column(String, unique=True, index=True)
    introduction = Column(String, nullable=True)
    password = Column(String)
    name = Column(String)
    account_createDate = Column(Date)
    lastLoginDate = Column(Date)

    following = relationship("FollowingModel", foreign_keys=[FollowingModel.user_id])
    followers = relationship("FollowerModel", foreign_keys=[FollowerModel.user_id])
    articles = relationship("ArticleModel", cascade="all, delete-orphan")
    comments = relationship('CommentModel', back_populates='user', cascade='all, delete-orphan')
    collections = relationship("ArticleModel", secondary="article_collections", back_populates="collected_by")
    images = relationship("ImageModel", back_populates="user")



