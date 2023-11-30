FROM python:3.11
ENV GIT_REVISION=$GIT_COMMIT

COPY ./ /backend/

WORKDIR /backend/
RUN echo "${GIT_REVISION}" >> REVISION

RUN pip install poetry
RUN poetry install --only main

CMD ["poetry", "run", "uvicorn", "api.main:api", "--host", "0.0.0.0", "--port", "81"]