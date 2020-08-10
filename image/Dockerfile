FROM centos:7

MAINTAINER "KarimFadl" <kareemfadl10@gmail.com>

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && rpm -Uvh https://rpms.remirepo.net/enterprise/remi-release-7.rpm

# normal updates
RUN yum -y update

# tools
RUN yum -y install epel-release iproute at curl crontabs git vim net-tools python-pip zip unzip graphviz aspell

# Install Nginx
RUN yum -y install nginx

#Install PHP 7
RUN yum --enablerepo=remi,remi-php74 install -y php-fpm php-cli php-pspell php-curl php-gd php-intl php-mysql php-xml php-xmlrpc php-ldap php-zip php-json php-opcache php-readline php-mbstring php-soap

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install supervisor
RUN yum -y install supervisor
RUN pip install supervisor-stdout
COPY ./config/supervisord.conf /etc/supervisord.conf

#RUN sed -i 's/^listen.allowed_clients/;listen.allowed_clients/' /etc/php-fpm.d/www.conf && \
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf

RUN mkdir -p /var/www/html && \
    mkdir -p /var/run/php-fpm && \
    chown -R nginx:nginx /var/www/html && \
    chown -R nginx:nginx /var/run/php-fpm

#RUN Nginx and PHP-FPM
COPY ./config/v-host.conf /etc/nginx/conf.d/default.conf
COPY ./config/nginx.conf /etc/nginx/
COPY ./config/www.conf /etc/php-fpm.d/www.conf

#Copy Source Code To Root Dir
COPY src/ /var/www/html/

EXPOSE 80

# Nginx worker_processes equal to number of cores
CMD ['sed -i "s/worker_processes.*/worker_processes `cat /proc/cpuinfo |grep processor|wc -l`;/" /etc/nginx/nginx.conf']

# try to run nginx
CMD ["/usr/bin/supervisord", "-n"]
