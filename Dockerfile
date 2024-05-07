FROM ruby:3.3.1-alpine

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

RUN bundle config set without 'development'

RUN bundle install

EXPOSE 51820/udp

CMD ["puma", "-C", "config/puma.rb"]
