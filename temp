FROM ubuntu/apache2:2.4-20.04_beta AS base

# LABEL maintainer="Micheal Waltz <dockerfiles@ecliptik.com>"

# Environment
ENV LANG=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Install runtime packages
RUN apt-get update \
    && apt-get install -y \
      perl

# Set app dir
WORKDIR /var/www/

# Intermediate build layer
FROM base AS build
#Update system and install packages
RUN apt-get update \
    && apt-get install -yq \
        build-essential \
        cpanminus \
        apache2-utils

# Install cpan modules
RUN cpanm CGI \
    DBI \
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

# ".htpasswd.dlp.agent" will be used when you create policies
RUN htpasswd -b -c /etc/apache2/.htpasswd.dlp.user dlpuser OpenDLP && \
    htpasswd -b -c /etc/apache2/.htpasswd.dlp.agent dlpuser OpenDLP

COPY OpenDLP/perl_modules /usr/local/lib/x86_64-linux-gnu/perl/5.30.0

# COPY apache2.conf /etc/apache2/apache2.conf

# COPY OpenDLP-2 html/OpenDLP

# Copy build artifacts from build layer
COPY --from=build /usr/local /usr/local

