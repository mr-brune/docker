# Stage 1: Build the Moodle-DL application
FROM python:3.11-slim AS python-builder
WORKDIR /build

# Install git and build dependencies for Moodle-DL
RUN apt-get update && \
    apt-get install -y --no-install-recommends git build-essential && \
    # Clone the Moodle-DL repository
    git clone https://github.com/C0D3D3V/Moodle-DL.git . && \
    # Install the package (moodle-dl and its Python dependencies)
    pip install --no-cache-dir . && \
    # Clean up build dependencies
    apt-get purge -y --auto-remove git build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Stage 2: Get a static ffmpeg binary
FROM jrottenberg/ffmpeg:4.4-alpine AS ffmpeg-builder
# This stage is just to copy the ffmpeg binary out

# Stage 3: Assemble the final, lean image
FROM python:3.11-slim
WORKDIR /app

# Python runtime is already in python:3.11-slim
# No need to apt-get update or install python again

# Copy the installed moodle-dl package and its dependencies from the python-builder stage
COPY --from=python-builder /usr/local/lib/python3.11/site-packages/ /usr/local/lib/python3.11/site-packages/
COPY --from=python-builder /usr/local/bin/moodle-dl /usr/local/bin/moodle-dl

# Copy the static ffmpeg binary from the ffmpeg-builder stage
COPY --from=ffmpeg-builder /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg

# Create a volume for downloaded files (as before)
VOLUME /files

# Set the entrypoint (as before)
ENTRYPOINT ["moodle-dl", "--path", "/files"]
