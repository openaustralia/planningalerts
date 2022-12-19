# TODO: Upgrade ruby as soon as we can
FROM ruby:2.7.4
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
# TODO: Upgrade bundler as soon as we can
RUN gem install bundler:1.17.3
RUN bundle install

ENTRYPOINT ["./entrypoint.sh"]

CMD ["bin/rails", "server", "-p", "3000", "-b", "0.0.0.0"]
