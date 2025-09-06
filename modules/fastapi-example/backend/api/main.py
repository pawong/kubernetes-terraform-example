import socket
import os
import time

from typing import Union

from fastapi import FastAPI, APIRouter

from api import eight_ball

api = FastAPI()
router = APIRouter()


@api.get("/")
def read_root():
    return {"Hello": "World"}


@api.get("/alive")
def keep_alive():
    return "I'm alive!"


@api.get("/health")
def health():
    return {
        "git_hash": os.environ["GIT_HASH"],
        "hostname": os.uname().nodename,
        "ip_address": socket.gethostbyname(socket.gethostname()),
        "server_time": int(time.time()),
    }


@api.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}


router.include_router(eight_ball.router, prefix="/8ball", tags=["eight_ball"])
api.include_router(router)
