import random

from typing import Union

from fastapi import FastAPI, HTTPException

api = FastAPI()


@api.get("/")
def read_root():
    return {"Hello": "World"}


@api.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}


answers = [
    "It is certain",
    "It is decidedly so",
    "Without a doubt",
    "Yes definitely",
    "You may rely on it",
    "As I see it, yes",
    "Most likely",
    "Outlook good",
    "Yes",
    "Signs point to yes",
    "Reply hazy try again",
    "Ask again later",
    "Better not tell you now",
    "Cannot predict now",
    "Concentrate and ask again",
    "Don't count on it",
    "My reply is no",
    "My sources say no",
    "Outlook not so good",
    "Very doubtful",
]


@api.get("/8ball")
def get_answer_only():
    """8ball get answer only endpoint"""
    return answers[random.randint(0, len(answers) - 1)]


@api.post("/8ball")
def get_answer(req):
    """8ball post answer endpoint"""
    question = req.question
    if question is None or not len(question):
        raise HTTPException(
            status_code=400,
            detail="Invalid formed question",
        )
    return {
        "answer": answers[random.randint(0, len(answers) - 1)],
        "question": question,
    }
