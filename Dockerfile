FROM php:7.4.0-apache

RUN a2enmod rewrite

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
    curl \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick

# install the PHP extensions we need
RUN pecl install mcrypt-1.0.3 \
    && docker-php-ext-enable mcrypt
RUN docker-php-ext-install -j$(nproc) iconv \
    pdo pdo_mysql mysqli gd
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/

RUN docker-php-ext-install exif && \
    docker-php-ext-enable exif

RUN curl -J -L -s -k \
    'https://github.com/omeka/Omeka/releases/download/v2.8/omeka-2.8.zip' \
    -o /var/www/omeka.zip \
    &&  unzip -q /var/www/omeka.zip -d /var/www/ \
    &&  rm /var/www/omeka.zip \
    &&  rm -rf /var/www/html \
    &&  mv /var/www/omeka-2.8 /var/www/html \
    &&  chown -R www-data:www-data /var/www/html

COPY ./db.ini /var/www/html/db.ini
COPY ./.htaccess /var/www/html/.htaccess
COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml

VOLUME /var/www/html

CMD ["apache2-foreground"]
