FROM php:7-fpm

MAINTAINER suncombo@gmail.com

# Install selected extensions and other stuff
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev git mysql-client libxml2-dev cron \
&& apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
&& docker-php-ext-install gd mbstring opcache pdo pdo_mysql pdo_pgsql zip xmlrpc

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini


# Install Composer and make it available in the PATH
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

#RUN mkdir --parents /opt/drush-7.x \
#&& cd /opt/drush-7.x \
#&& composer init --require=drush/drush:7.* -n \
#&& composer config bin-dir /usr/local/bin \
#&& composer install

# Download latest stable release using the code below or browse to github.com/drush-ops/drush/releases.
RUN php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > drush \
# Or use our upcoming release: php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush-unstable.phar');" > drush

# Test your install.
&& php drush core-status \

# Make `drush` executable as a command from anywhere. Destination can be anywhere on $PATH.
&& chmod +x drush \
&& mv drush /usr/local/bin

# Optional. Enrich the bash startup file with completion and aliases.
#&& drush init

RUN service exim4 restart

WORKDIR "/var/www/php"
