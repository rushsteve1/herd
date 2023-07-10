FROM ruby:alpine

RUN apk update && apk add --no-cache build-base

WORKDIR /usr/herd

COPY . .

RUN bundle install
RUN bundle exec whenever --update-crontab

CMD ["crond", "-f"]
