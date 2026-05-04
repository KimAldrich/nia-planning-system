FROM php:8.2-apache

# 1. Install development packages and clean up apt cache.
RUN apt-get update && apt-get install -y \
    unzip \
    && docker-php-ext-install pdo bcmath \
    && rm -rf /var/lib/apt/lists/*

# 2. Apache Configuration: Point to /public (important for Laravel)
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf
RUN a2enmod rewrite

# 3. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Set working directory
WORKDIR /var/www/html

# 5. Copy application source
COPY . .

# Set Composer memory limit to unlimited
ENV COMPOSER_MEMORY_LIMIT=-1

# Then run your install command
RUN composer install --no-dev --optimize-autoloader

# 7. Fix permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 8. Expose port 80
EXPOSE 80
