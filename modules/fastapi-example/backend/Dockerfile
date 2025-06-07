FROM python:3.12-bookworm
ARG GIT_HASH

COPY ./ /backend/
WORKDIR /backend/

ENV GIT_HASH=${GIT_HASH}
RUN echo ${GIT_HASH} > REVISION

RUN apt update
RUN pip3 install poetry
RUN poetry install --only main --no-root

CMD ["poetry", "run", "uvicorn", "api.main:api", "--host", "0.0.0.0", "--port", "81"]
