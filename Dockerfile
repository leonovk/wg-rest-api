FROM ruby:3.4.1-alpine

WORKDIR /app

COPY . .

RUN apk update \
    && apk --no-cache --update add build-base 

# Install Linux packages
RUN apk add --no-cache \
    dpkg \
    dumb-init \
    iptables \
    iptables-legacy \
    wireguard-tools

# Use iptables-legacy
RUN update-alternatives --install \
    /sbin/iptables iptables \
    /sbin/iptables-legacy 10 --slave \
    /sbin/iptables-restore iptables-restore \
    /sbin/iptables-legacy-restore --slave \
    /sbin/iptables-save iptables-save \
    /sbin/iptables-legacy-save

RUN bundle config set without 'development rerun test'

RUN bundle install

CMD ["puma", "-C", "config/puma.rb"]
