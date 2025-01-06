# Use official PHP image with Apache
FROM php:8.1-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    git \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql opcache \
    && a2enmod rewrite

# Set working directory inside the container
WORKDIR /var/www/html

# Copy application files to the container
COPY . /var/www/html

# Set correct file permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Laravel dependencies with Composer
RUN composer install --no-dev --optimize-autoloader --prefer-dist

# Expose port 80 for Apache
EXPOSE 80

# Set entrypoint to run Apache in the foreground
CMD ["apache2-foreground"]
