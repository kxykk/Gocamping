# followerModel.py
from sqlalchemy import Column, Integer, ForeignKey
from database import Base

class FollowerModel(Base):
    __tablename__ = "follower"

    user_id = Column(Integer, ForeignKey("user.user_id"), primary_key=True)
    follower_id = Column(Integer, ForeignKey("user.user_id"), primary_key=True)