FROM debian:stable AS php

RUN apt update \
	&& apt install -yq wget git unzip \
	&& apt install -yq lsb-release apt-transport-https ca-certificates

#enable php repository
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
	&& echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
	&& apt update

#Install php
RUN apt install -yq php8.0 \
	php8.0-common \
	php8.0-curl php8.0-gd php8.0-intl php-json php8.0-mbstring php8.0-xml php8.0-zip php8.0-pgsql php8.0-fpm

#Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php --install-dir=bin --filename=composer \
	&& php -r "unlink('composer-setup.php');"

#Install Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash \
	&& mv /root/.symfony/bin/symfony /bin/symfony

#Configure Php FPM
COPY ./docker/php/docker.conf /etc/php/8.0/fpm/pool.d/www.conf
COPY ./docker/php/php-fpm.conf /etc/php/8.0/fpm/php-fpm.conf
EXPOSE 9000
CMD ["php-fpm8.0","-F"]

WORKDIR /srv/app
RUN echo "umask 002" >> ~/.bashrc
