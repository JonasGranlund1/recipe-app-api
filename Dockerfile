FROM python:3.9-alpine3.13

# Who is going to maintain the base image.
LABEL maintainer="jonsagranlund" 

#Prevents output from being buffered or delayed from Python to the console. For example for debug messages. 
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app

EXPOSE 8000


# One single run command to avoid create multiple layers. Create virtual env to avoid conflicting dependencies between base image.
# Upgrade pip
# Install the requirements inside the docker image (full path to pip)
# Remove tmp files to keep docker image as lightweight as possible
# Add a new user inside the image. Best practice not to use the root user. Security risk.


ARG DEV=false
RUN python -m venv /py && \                             
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \   
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \                                           
        --disabled-password \
        --no-create-home \
        django-user
        
ENV PATH="/py/bin:$PATH"

USER django-user

