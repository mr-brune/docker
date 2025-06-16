# Use a small base image
FROM alpine:latest

# Metadata
LABEL maintainer="Mrbrune"
LABEL description="Converts FLAC files to Opus, with an external exclusion list."

# Install dependencies: ffmpeg (with libopus), bash, findutils, coreutils
RUN apk update && \
    apk add --no-cache ffmpeg bash findutils coreutils dos2unix && \
    rm -rf /var/cache/apk/*

# Set environment variables
ENV BITRATE="192k"
ENV MUSIC_DIR="/music"
ENV APP_DIR="/app"
ENV EXCLUDE_FILE_NAME="exclude_paths.list"

# Create a directory for the conversion script and exclusion list
WORKDIR ${APP_DIR}

# Copy the conversion script and the default exclusion list
COPY convert.sh .
COPY exclude_paths.list .

RUN dos2unix convert.sh
# Make the script executable
RUN chmod +x convert.sh

# Set the working directory for the conversion (where music will be mounted)
WORKDIR ${MUSIC_DIR}

# Define the entrypoint
ENTRYPOINT ["/app/convert.sh"]

# Default command (can be overridden if needed, but entrypoint handles execution)
CMD []
