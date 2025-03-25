FROM ruby:3.4.2-alpine

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
    /usr/sbin/iptables iptables \
    /usr/sbin/iptables-legacy 10 --slave \
    /usr/sbin/iptables-restore iptables-restore \
    /usr/sbin/iptables-legacy-restore --slave \
    /usr/sbin/iptables-save iptables-save \
    /usr/sbin/iptables-legacy-save

RUN bundle config set without 'development rerun test'

RUN bundle install

CMD ["puma", "-C", "config/puma.rb"]
