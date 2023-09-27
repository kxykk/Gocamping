# comment_routes.py
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from .comment_crud import get_comment, create_comment, update_comment, delete_comment,get_comments_by_article_id
from .comment_schema import Comment as  CommentCreate, CommentUpdate, Comment
from api.server_response.server_response_model import ServerResponse
from typing import List

import database 

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

router = APIRouter()


@router.post("/", response_model=ServerResponse)
async def create_a_comment(comment: CommentCreate, db: Session = Depends(get_db)):
    created_comment = create_comment(db, comment)
    return ServerResponse(success=True, comment=created_comment)

@router.get("/by_article_id/{article_id}", response_model=ServerResponse)
async def read_comments_by_article_id(article_id: int, db: Session = Depends(get_db)):
    comments = get_comments_by_article_id(db, article_id)
    if comments is None or not comments:
        return ServerResponse(success=False, errorCode="No comments found for this article")
    
    response_comments = [Comment(**vars(comment)) for comment in comments]
    return ServerResponse(success=True, comments=response_comments)







@router.get("/{comment_id}", response_model=ServerResponse)
async def read_a_comment(comment_id: int, db: Session = Depends(get_db)):
    db_comment = get_comment(db, comment_id)
    if db_comment is None:
        return ServerResponse(success=False, errorCode="Comment not found")
    return ServerResponse(success=True, comment=Comment(**db_comment.dict()))

@router.put("/{comment_id}", response_model=ServerResponse)
async def update_a_comment(comment_id: int, comment: CommentUpdate, db: Session = Depends(get_db)):
    comment.comment_id = comment_id 
    updated_comment = update_comment(db, comment)
    if updated_comment is None:
        return ServerResponse(success=False, errorCode="Comment not found or failed to update")
    return ServerResponse(success=True, comment=Comment(**updated_comment.dict()))


@router.delete("/{comment_id}")
async def delete_a_comment(comment_id: int, db: Session = Depends(get_db)):
    db_comment = delete_comment(db, comment_id)
    if db_comment is None:
        return ServerResponse(success=False, errorCode="Comment not found")
    return ServerResponse(success=True, message="Comment successfully deleted")
