FROM ruby:3.4.7-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libyaml-dev \
    nodejs \
    npm \
    curl \
    git \
    imagemagick \
    libmagickwand-dev && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile
COPY Gemfile ./

# Install gems (Gemfile.lock will be generated if it doesn't exist)
RUN bundle install

# Copy the rest of the application
COPY . .

# Create necessary directories
RUN mkdir -p tmp/pids log storage tmp/storage

# Expose port
EXPOSE 3000

# Start the server
CMD ["rails", "server", "-b", "0.0.0.0"]

