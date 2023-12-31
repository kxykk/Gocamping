# following_schemas.py
from pydantic import BaseModel

class FollowingBase(BaseModel):
    user_id: int
    following_id: int

class FollowingCreate(FollowingBase):
    pass

class Following(FollowingBase):
    pass

    class Config:
        from_attributes = True