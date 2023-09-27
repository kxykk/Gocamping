from pydantic import BaseModel
from typing import List, Union
from api.user.user_schema import User
from api.article.article_schema import Article, ArticleIdAndTitle
from api.image.image_schema import Image
from api.text.text_schema import Text 
from api.camp.camp_schema import Camp
from api.comment.comment_schema import Comment

class CombinedItem(BaseModel):
    type: str
    item: Union[Image, Text]
    sortNumber: int    

class ServerResponse(BaseModel):
    success: bool
    errorCode: str = None
    user: User = None
    article: Article = None
    articles: List[ArticleIdAndTitle] = None
    image: Image = None
    images: List[Image] = None
    text: Text = None
    texts: List[Text] = None
    combinedItems: List[CombinedItem] = None
    comment: Comment = None
    comments: List[Comment] = None
    camp: Camp = None
    camps: List[Camp] = None  



