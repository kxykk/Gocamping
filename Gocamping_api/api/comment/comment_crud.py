# comment_crud.py
from sqlalchemy.orm import Session
from .comment_model import CommentModel
from .comment_schema import CommentCreate, CommentUpdate

def get_comment(db: Session, comment_id: int):
    return db.query(CommentModel).filter(CommentModel.comment_id == comment_id).first()

def get_comments(db: Session, skip: int = 0, limit: int = 100):
    return db.query(CommentModel).offset(skip).limit(limit).all()

def get_comments_by_article_id(db: Session, article_id: int, skip: int = 0, limit: int = 100):
    return db.query(CommentModel).filter(CommentModel.article_id == article_id).offset(skip).limit(limit).all()


def create_comment(db: Session, comment: CommentCreate):
    comment_dict = comment.dict()
    db_comment = CommentModel(**comment_dict)
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)
    return db_comment




def update_comment(db: Session, comment: CommentUpdate):
    db_comment = db.query(CommentModel).filter(CommentModel.comment_id == comment.comment_id).first()
    if db_comment is None:
        return None
    for var, value in vars(comment).items():
        setattr(db_comment, var, value) if value else None
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)
    return db_comment

def delete_comment(db: Session, comment_id: int):
    db_comment = db.query(CommentModel).filter(CommentModel.comment_id == comment_id).first()
    if db_comment is None:
        return None
    db.delete(db_comment)
    db.commit()
    return db_comment
