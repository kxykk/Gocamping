# following_schemas.py
from pydantic import BaseModel

class FollowerBase(BaseModel):
    user_id: int
    follower_id: int

class FollowerCreate(FollowerBase):
    pass

class Follower(FollowerBase):
    pass

    class Config:
        from_attributes = True