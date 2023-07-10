FROM ruby:alpine

WORKDIR /usr/herd

COPY . .

RUN bundle install
RUN bundle exec whenever --update-crontab

CMD ["crond", "-f"]
