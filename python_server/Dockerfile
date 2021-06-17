# FROM python:3.9-alpine
FROM dariocast/algorand-python3.9-alpine:latest

COPY /app /app
COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip install -r requirements.txt
CMD [ "python", "rest_server.py" ]