# imageModel.py
from sqlalchemy import Column, Integer, String, ForeignKey, Enum
from sqlalchemy.orm import relationship
from api.image.image_schema import ImageType
from database import Base

class ImageModel(Base):
    __tablename__ = "image"

    image_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    article_id = Column(Integer, ForeignKey("article.article_id"))
    user_id = Column(Integer, ForeignKey("user.user_id"))
    camp_id = Column(Integer, ForeignKey("camp.camp_id"))
    image_sortNumber = Column(Integer)
    imageURL = Column(String(255))
    image_format = Column(String(255))
    image_size = Column(Integer)
    image_type = Column(Enum(ImageType), nullable=False)    

    article = relationship("ArticleModel", back_populates="images", single_parent=True)
    user = relationship("UserModel", back_populates="images")
    camp = relationship("CampModel", back_populates="images")



