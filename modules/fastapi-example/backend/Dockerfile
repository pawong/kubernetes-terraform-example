FROM python:3.12-bookworm
ARG GIT_COMMIT

COPY ./ /backend/
WORKDIR /backend/

ENV GIT_COMMIT=${GIT_COMMIT}
RUN echo ${GIT_COMMIT} > REVISION

RUN apt update
RUN pip3 install poetry
RUN poetry install --only main --no-root

CMD ["poetry", "run", "uvicorn", "api.main:api", "--host", "0.0.0.0", "--port", "81"]
