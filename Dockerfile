FROM ruby:latest-alpine

WORDIR /usr/herd

COPY . .

RUN bundle exec whenever --update-crontab

CMD ["exec", "crond", "-f"]
