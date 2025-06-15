# Stage 1: Build the application
FROM python:3.11-slim AS builder
WORKDIR /build

# Install git and build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends git build-essential && \
    # Clone the Moodle-DL repository
    git clone https://github.com/C0D3D3V/Moodle-DL.git . && \
    # Install the package
    pip install --no-cache-dir . && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Stage 2: Create the final image
FROM python:3.11-slim
WORKDIR /app

# Copy only the installed package from the builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/moodle-dl /usr/local/bin/moodle-dl

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a volume for downloaded files
VOLUME /files

# Set the entrypoint
ENTRYPOINT ["moodle-dl", "--path", "/files"]
