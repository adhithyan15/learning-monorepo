# Use official PHP CLI image with necessary extensions
FROM php:8.4-cli

# Install useful system tools and Composer (manually)
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer --version

# Set working directory inside container
WORKDIR /workspace

# Copy all project files into container
COPY . .

# Install PHP dependencies with Composer
RUN composer install

# Default command: start a bash shell
CMD ["bash"]