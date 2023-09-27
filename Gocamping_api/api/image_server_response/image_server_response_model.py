from pydantic import BaseModel
from api.image.image_schema import Image

class ImageServerResponse(BaseModel):
    image: Image = None