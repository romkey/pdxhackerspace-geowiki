FROM ruby:4.0.6-slim

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

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application
COPY . .

# Create necessary directories
RUN mkdir -p tmp/pids log storage tmp/storage

# Expose port
EXPOSE 3000

# Start the server (migrations run via docker-compose command override)
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails db:prepare && rails server -b 0.0.0.0"]

