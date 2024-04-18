FROM php:8.2-fpm-bullseye

ENV TERM=xterm

RUN apt-get clean \
	#	&& apt-get update \
	&& apt-get --allow-releaseinfo-change update \
	&& apt-get install -y lsof nano less git locales

RUN echo 'fr_FR.UTF-8 UTF-8' > /etc/locale.gen \
	&& /usr/sbin/locale-gen

RUN apt-get update \
	&& apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libxslt-dev libicu-dev libxml2-dev libpq-dev libedit-dev mariadb-client libzip-dev nodejs npm \
	&& apt-get install -y --no-install-recommends libmagickwand-dev \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j4 gd xsl zip intl gettext soap pdo_pgsql pdo_mysql mysqli pgsql opcache \
	&& pecl install redis \
	&& docker-php-ext-enable redis 

# apt-get install -y libgeoip-dev
# pecl install geoip-1.1.1 imagick
# docker-php-ext-enable geoip imagick

RUN { \
	echo 'opcache.memory_consumption=128'; \
	echo 'opcache.interned_strings_buffer=8'; \
	echo 'opcache.max_accelerated_files=4000'; \
	echo 'opcache.revalidate_freq=60'; \
	echo 'opcache.fast_shutdown=1'; \
	echo 'opcache.enable_cli=1'; \
	} >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

COPY zz-logformat.conf /usr/local/etc/php-fpm.d/
COPY php.ini /usr/local/etc/php/conf.d/

RUN (curl --silent --show-error https://getcomposer.org/installer | php) \
	&& mv composer.phar /usr/local/bin/composer

# Symfony CLI
RUN (curl --silent --show-error https://get.symfony.com/cli/installer | bash) \
	&& mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

RUN apt-get clean \
	&& rm -rf /var/lib/apt/lists/
