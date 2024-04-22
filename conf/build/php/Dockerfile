FROM php:8.2-fpm-bullseye

ENV TERM=xterm

RUN apt-get clean \
	#	&& apt-get update \
	&& apt-get --allow-releaseinfo-change update \
	&& apt-get install -y lsof nano less git locales

RUN echo 'fr_FR.UTF-8 UTF-8' > /etc/locale.gen \
	&& /usr/sbin/locale-gen

RUN apt-get update \
	&& apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libxslt-dev libicu-dev libxml2-dev libpq-dev libedit-dev mariadb-client libzip-dev \
	&& apt-get install -y --no-install-recommends libmagickwand-dev \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j4 gd xsl zip intl gettext soap pdo_pgsql pdo_mysql mysqli pgsql opcache \
	&& pecl install redis \
	&& docker-php-ext-enable redis 

# apt-get install -y libgeoip-dev
# pecl install geoip-1.1.1 imagick
# docker-php-ext-enable geoip imagick

# Installer nvm avec Node.js et npm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 20.12.0

RUN mkdir -p $NVM_DIR \
	&& curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash \
	&& . $NVM_DIR/nvm.sh \
	&& nvm install $NODE_VERSION \
	&& nvm alias default $NODE_VERSION \
	&& nvm use default

# Ajouter node et npm aux chemins
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Vérifier l'installation
RUN node -v
RUN npm -v

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
