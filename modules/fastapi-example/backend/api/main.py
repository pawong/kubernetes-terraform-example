import random

from typing import Union

from fastapi import FastAPI, APIRouter

from api import eight_ball

api = FastAPI()
router = APIRouter()

api.include_router(router)


@api.get("/")
def read_root():
    return {"Hello": "World"}


@api.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}


router.include_router(eight_ball.router, tags=["eight_ball"])
