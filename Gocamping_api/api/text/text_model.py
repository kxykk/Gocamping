# textModel.py
from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class TextModel(Base):
    __tablename__ = "text"

    text_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    article_id = Column(Integer, ForeignKey("article.article_id"))
    text_sortNumber = Column(Integer)
    content = Column(String(255))

    article = relationship("ArticleModel", back_populates="texts", single_parent=True)

