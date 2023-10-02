# main.py
from fastapi import FastAPI

import subprocess, re
from api.user.user_routes import router as user_router
from api.article.article_routes import router as article_router
from api.article_collection.articel_collection_routes import router as article_collection_router
from api.camp.camp_routes import router as camp_router
from api.comment.comment_routes import router as comment_router
from api.follower.follower_routes import router as follower_router
from api.following.following_routes import router as following_router
from api.image.image_routes import router as image_router
from api.text.text_routes import router as text_router
from fastapi.staticfiles import StaticFiles
import pyrebase
import time
import threading
from subprocess import run, PIPE, Popen


app = FastAPI()

app.mount("/root/Gocamping_api/pictures/", StaticFiles(directory="/root/Gocamping_api/pictures"), name="pictures")
app.include_router(user_router, prefix="/user", tags=["user"])
app.include_router(article_router, prefix="/article", tags=["article"])
app.include_router(article_collection_router, prefix="/article_collection", tags=["article_collection"])
app.include_router(camp_router, prefix="/camp", tags=["camp"])
app.include_router(comment_router, prefix="/comment", tags=["comment"])
app.include_router(follower_router, prefix="/follower", tags=["follower"])
app.include_router(following_router, prefix="/following", tags=["following"])
app.include_router(image_router, prefix="/image", tags=["image"])
app.include_router(text_router, prefix="/text", tags=["text"])

@app.get("/")
def read_status():
    return {"status": "API is working"}


