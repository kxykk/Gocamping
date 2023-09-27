# followingModel.py
from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class FollowingModel(Base):
    __tablename__ = "following"

    user_id = Column(Integer, ForeignKey("user.user_id"), primary_key=True)
    following_id = Column(Integer, ForeignKey("user.user_id"), primary_key=True)