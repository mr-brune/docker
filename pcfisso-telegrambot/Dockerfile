# Use a slim Python Alpine image as the base
FROM python:3.13-alpine

# Install the 'ping' utility (from iputils) and the python-telegram-bot library
# Using --no-cache for apk and --no-cache-dir for pip helps keep the image size down
RUN apk add --no-cache iputils-ping && \
    pip install --no-cache-dir python-telegram-bot

# Set the working directory in the container
WORKDIR /app

# The STATE_FILE (PCfisso_state.txt) will be created by your script in /app.
# If you map a volume to /app or for PCfisso_state.txt, its state will be persisted.

# Command to run your Python application
CMD ["python", "PCfisso.py"]
