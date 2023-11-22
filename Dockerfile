FROM salttest/ubuntu-13.04 AS base
# LABEL maintainer="Micheal Waltz <dockerfiles@ecliptik.com>"

# Environment
ENV LANG=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Install runtime packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y \
    perl \
    apache2



# Set app dir
WORKDIR /var/www/

# Intermediate build layer
FROM base AS build
#Update system and install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -yq \
    build-essential \
    cpanminus \
    apache2-utils \
    libdbd-mysql-perl

# Install cpan modules CGI \
RUN cpanm DBI \
    # Filesys::SmbClient \
    Proc::Queue \
    XML::Writer \
    MIME::Base64 \
    # DBD::Sybase \
    Algorithm::LUHN \
    Time::HiRes \
    Digest::MD5 \
    File::Path \
    Archive::Extract \
    Archive::Zip \
    Data::MessagePack

# Runtime layer
FROM base AS run

RUN apt-get install sshfs -y 

# ".htpasswd.dlp.agent" will be used when you create policies
RUN htpasswd -b -c /etc/apache2/.htpasswd.dlp.user dlpuser OpenDLP && \
    htpasswd -b -c /etc/apache2/.htpasswd.dlp.agent dlpuser OpenDLP 

# RUN gpasswd -a root fuse && gpasswd -a www-data fuse  
    
COPY OpenDLP/perl_modules/ /usr/lib/perl5/

# COPY ssl /etc/apache2/ssl

# COPY OpenDLP-2 html/OpenDLP

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

RUN a2enmod rewrite && a2enmod ssl



# Copy build artifacts from build layer
COPY --from=build /usr/local /usr/local

# RUN a2ensite default

RUN apache2ctl start


