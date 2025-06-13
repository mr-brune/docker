FROM python:3.13-alpine

WORKDIR /app

# Install required system dependencies
RUN apk add --no-cache \
    ffmpeg \
    opus \
    opus-dev

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application

CMD ["python", "discord1.py"]
