# TODO: Upgrade ruby as soon as we can
FROM ruby:2.7.4
WORKDIR /app

# Run everything as a non-root "deploy" user
RUN groupadd --gid 1000 deploy \
    && useradd --uid 1000 --gid 1000 -m deploy

# Add sudo support so that we can install software by hand later on
RUN apt-get update \
    && apt-get install -y sudo \
    && echo deploy ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/deploy \
    && chmod 0440 /etc/sudoers.d/deploy

USER deploy

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
# TODO: Upgrade bundler as soon as we can
RUN gem install bundler:1.17.3
RUN bundle install

ENTRYPOINT ["./entrypoint.sh"]

CMD ["bin/rails", "server", "-p", "3000", "-b", "0.0.0.0"]
