FROM --platform=linux/amd64 ubuntu:20.04

LABEL maintainer="Kevin Mahoney <kevin@mandolin.com>"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yqq install software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get install -y python3.9 python3.9-dev curl python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

RUN pip install --no-cache-dir "uvicorn[standard]" gunicorn

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

COPY ./gunicorn_conf.py /gunicorn_conf.py

COPY ./start-reload.sh /start-reload.sh
RUN chmod +x /start-reload.sh

COPY ./app /app
WORKDIR /app/

ENV PYTHONPATH=/app

EXPOSE 80

# Unset python3 entrypoint from base image.
ENTRYPOINT [""]

# Run the start script, it will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Gunicorn with Uvicorn
CMD ["/start.sh"]
