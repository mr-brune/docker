# Use Alpine Python 3.13
FROM python:3.13-alpine

# Install build tools, git and ffmpeg, install moodle-dl, then clean up
RUN apk add --no-cache --virtual .build-deps \
      build-base git \
    && apk add --no-cache ffmpeg \
    && pip install --no-cache-dir git+https://github.com/C0D3D3V/Moodle-DL.git \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

WORKDIR /files
VOLUME /files

ENTRYPOINT ["moodle-dl", "--path", "/files"]
