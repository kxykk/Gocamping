from typing import Optional
from pydantic import BaseModel

class CampBase(BaseModel):
    camp_name: str
    camp_city: str
    camp_area: str
    latitude_longitude_wgs84: str
    camp_situation: str
    camp_location:str
    camp_phone: Optional[str] = None
    camp_website: Optional[str] = None

class CampCreate(CampBase):
    pass

class CampUpdate(CampBase):
    camp_id: int

class Camp(CampUpdate):
    pass
