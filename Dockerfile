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

# Use iptables-legacy
RUN update-alternatives --install \
    /sbin/iptables iptables \
    /sbin/iptables-legacy 10 --slave \
    /sbin/iptables-restore iptables-restore \
    /sbin/iptables-legacy-restore --slave \
    /sbin/iptables-save iptables-save \
    /sbin/iptables-legacy-save

RUN bundle config set without 'development rerun'

RUN bundle install

# Copy events_cron file to the cron.d directory
COPY events_cron /etc/cron.d/events_cron
 
# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/events_cron

# Apply cron job
RUN crontab /etc/cron.d/events_cron
 
# Create the log file to be able to run tail
RUN touch /var/log/cron.log

CMD ["puma", "-C", "config/puma.rb"]
