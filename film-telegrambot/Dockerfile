FROM python:3.13-alpine

# Set the working directory in the container
WORKDIR /app

# Copy the Python script into the container
COPY film.py /app/

# Install dependencies
# difflib and asyncio are part of the standard Python library
RUN pip install --no-cache-dir requests beautifulsoup4 python-telegram-bot

# Command to run the script when the container starts
CMD ["python", "film.py"]
