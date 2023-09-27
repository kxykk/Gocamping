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
serveo_url = None


def start_serveo():
    global serveo_url
    
    # 延遲啟動 autossh
    time.sleep(3)
    
    process = Popen(["autossh", "-M", "0", "-R", "80:localhost:8000", "serveo.net"], stdout=PIPE, stderr=PIPE, text=True)
    
    while True:
        output = process.stdout.readline().strip()
        match = re.search(r"Forwarding HTTP traffic from (.*)", output)
        if match:
            serveo_url = match.group(1)
            print(f"Serveo URL is {serveo_url}")
            
            # 將 URL 寫入 Firebase
            print(f"Writing {serveo_url} to Firebase")  
            db.child("serveo_urls").child("url").set(serveo_url)
            print(f"Wrote {serveo_url} to Firebase")  
            break
        elif not output:
            break
        else:
            print(f"Waiting for Serveo URL...")




@app.on_event("startup")
async def startup_event():
    threading.Thread(target=start_serveo).start()

config = {
  "apiKey": "AIzaSyDVJHn2Xi5nhzoeXtq3dGi4FSsFMyU-RE0",
  "authDomain": "gocamping-399506.firebaseapp.com",
  "databaseURL": "https://gocamping-399506-default-rtdb.firebaseio.com/", 
  "storageBucket": "gocamping-399506.appspot.com"
}

firebase = pyrebase.initialize_app(config)
db = firebase.database()


@app.get("/get_serveo_url")
def get_serveo_url():
    return {"serveo_url": serveo_url}

app.mount("/Users/kang/Desktop/gocamping/pictures/", StaticFiles(directory="pictures"), name="pictures")
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


