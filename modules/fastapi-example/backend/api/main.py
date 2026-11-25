import socket
import os
import time
import asyncio

from contextlib import asynccontextmanager
from typing import Union

import aiohttp

from fastapi import FastAPI, APIRouter, Request

from api import eight_ball


@asynccontextmanager
async def lifespan(api: FastAPI):

    connector = aiohttp.TCPConnector(
        limit=100,
        limit_per_host=100,
        keepalive_timeout=30,
    )

    timeout = aiohttp.ClientTimeout(total=10)

    api.state.http = aiohttp.ClientSession(
        connector=connector,
        timeout=timeout,
    )

    api.state.request_semaphore = asyncio.Semaphore(100)

    yield

    await api.state.http.close()


api = FastAPI(lifespan=lifespan)
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


@api.get("/google")
async def google(request: Request):

    async with request.app.state.request_semaphore:

        async with request.app.state.http.get("https://www.google.com") as response:

            return {
                "status_code": response.status,
                "url": str(response.url),
                "response": (await response.text())[:500],
            }


router.include_router(
    eight_ball.router,
    prefix="/8ball",
    tags=["eight_ball"],
)

api.include_router(router)
