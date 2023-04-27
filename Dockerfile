FROM ruby:3.1.3
WORKDIR /app

# Run everything as a non-root "deploy" user
RUN groupadd --gid 1000 deploy \
    && useradd --uid 1000 --gid 1000 -m deploy

# Add sudo support so that we can install software by hand later on
RUN apt-get update \
    && apt-get install -y sudo \
    && echo deploy ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/deploy \
    && chmod 0440 /etc/sudoers.d/deploy

# Needed for sorbet extension for vscode
RUN apt install watchman

# Needed for rgeo geos support. See https://github.com/rgeo/rgeo/issues/227#issuecomment-1145169888
RUN apt-get install -y libgeos++-dev libgeos-dev

# Support for PA handling incoming email
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y postfix
RUN postconf -e "maillog_file=/dev/stdout"

USER deploy

COPY --chown=deploy:deploy Gemfile /app/Gemfile
COPY --chown=deploy:deploy Gemfile.lock /app/Gemfile.lock
RUN bundle install

ENTRYPOINT ["./entrypoint.sh"]

CMD ["bin/rails", "server", "-p", "3000", "-b", "0.0.0.0"]
