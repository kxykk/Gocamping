# text_schemas.py
from pydantic import BaseModel

class TextBase(BaseModel):
    article_id: int
    text_sortNumber: int
    content: str

class TextCreate(TextBase):
    pass

class TextUpdate(TextBase):
    pass

class Text(TextBase):
    text_id: int

    class Config:
        from_attributes = True
