FROM python:3.9-alpine

COPY ./requirements.txt ./requirements.txt

ENV TZ="Europe/Rome"
RUN apk add --no-cache --virtual .pynacl_deps build-base python3-dev libffi-dev tzdata
RUN pip install -r requirements.txt
