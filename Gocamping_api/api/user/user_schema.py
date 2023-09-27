from typing import Optional
from pydantic import BaseModel
from datetime import date

# password還要再加密，參考php user_crud_maim_class_dao.php
class UserBase(BaseModel):
    email: str
    name: str
    account_createDate: date
    lastLoginDate: Optional[date] = None
    introduction: Optional[str] = None

class UserCreate(UserBase):
    password: str

class User(UserBase):
    user_id: int
    password: Optional[str] = None 

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    email: Optional[str] = None
    name: Optional[str] = None
    password: Optional[str] = None
    introduction: Optional[str] = None

    class Config:
        from_attributes = True
