# comment_schema.py
from pydantic import BaseModel
from typing import Optional

class CommentBase(BaseModel):
    article_id: int
    user_id: int
    comment: str

class CommentCreate(CommentBase): 
    pass

class CommentUpdate(CommentBase):
    pass


class Comment(BaseModel): 
    comment_id: Optional[int] = None
    article_id: Optional[int] = None
    user_id: Optional[int] = None
    comment: Optional[str] = None

    class Config:
        from_attributes = True

