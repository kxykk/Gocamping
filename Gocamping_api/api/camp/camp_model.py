from sqlalchemy import Column, Integer, String, Enum
from sqlalchemy.orm import relationship
from database import Base

class CampModel(Base):
    __tablename__ = "camp"

    camp_id = Column(Integer, primary_key=True, index=True)
    camp_name = Column(String(255))
    camp_city = Column(String(255))
    camp_area = Column(String(255))
    latitude_longitude_wgs84 = Column(String(255))
    camp_situation = Column(Enum('營業中','待清查','待確認'))
    camp_phone = Column(String(255))
    camp_website = Column(String(255))
    camp_location = Column(String(255))

    images = relationship("ImageModel", back_populates="camp")

