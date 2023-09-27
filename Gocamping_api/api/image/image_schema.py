# image_schemas.py
from pydantic import BaseModel
from typing import Optional
from enum import Enum


class ImageType(str, Enum):  
    title = "title" # type: ignore
    content = "content"
    user = "user"
    camp = "camp"

class ImageBase(BaseModel):
    article_id: Optional[int] = None
    user_id: Optional[int] = None
    camp_id: Optional[int] = None
    image_sortNumber: int
    imageURL: str
    image_format: str
    image_size: int
    image_type: ImageType    
    
    

class ImageCreate(ImageBase):
    pass

class ImageUpdate(ImageBase):
    pass

class Image(ImageBase):
    imageURL: str
    image_type: str

    class Config:
        from_attributes = True
        
