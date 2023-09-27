# commentModel.py
from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class CommentModel(Base):
    __tablename__ = "comment"

    comment_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    article_id = Column(Integer, ForeignKey("article.article_id"))
    user_id = Column(Integer, ForeignKey("user.user_id"))
    comment = Column(String(255))

    user = relationship('UserModel', back_populates='comments')
    article = relationship("ArticleModel", back_populates="comments", single_parent=True)

