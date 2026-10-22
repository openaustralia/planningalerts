# Matches production: Ubuntu 22.04 (jammy) with Ruby 3.3.4, which production runs through RVM. buildpack-deps is
# the base the official Ruby images use, so it brings the same development libraries for building gems.
FROM buildpack-deps:jammy

ARG RUBY_VERSION=3.3.4
# A fixed ruby-build release, so every build gets the same toolchain
ARG RUBY_BUILD_VERSION=v20261013
RUN git clone --depth 1 --branch "$RUBY_BUILD_VERSION" https://github.com/rbenv/ruby-build.git /tmp/ruby-build \
    && RUBY_CONFIGURE_OPTS=--disable-install-doc /tmp/ruby-build/bin/ruby-build "$RUBY_VERSION" /usr/local \
    && rm -rf /tmp/ruby-build

# UTF-8 like production; the official Ruby images set this, buildpack-deps doesn't
ENV LANG=C.UTF-8
# Gems live in /usr/local/bundle, as in the official Ruby images, which is where compose.yaml's gem_cache volume goes
ENV GEM_HOME=/usr/local/bundle BUNDLE_APP_CONFIG=/usr/local/bundle BUNDLE_SILENCE_ROOT_WARNING=1
ENV PATH=/usr/local/bundle/bin:$PATH
RUN mkdir -p /usr/local/bundle && chmod 1777 /usr/local/bundle

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
RUN apt install -y watchman

# Needed for rgeo geos support. See https://github.com/rgeo/rgeo/issues/227#issuecomment-1145169888
RUN apt-get install -y libgeos++-dev libgeos-dev

# Support for PA handling incoming email
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y postfix
RUN postconf -e "maillog_file=/dev/stdout"
COPY .devcontainer/virtual_alias /etc/postfix/virtual_alias
COPY .devcontainer/transport /etc/postfix/transport
COPY .devcontainer/incoming-email.sh /usr/local/bin/incoming-email.sh
RUN postconf -M -e "planningalerts/unix=planningalerts unix - n n - 50 pipe flags=R user=deploy directory=/app argv=/usr/local/bin/incoming-email.sh"
RUN postconf -e "virtual_alias_maps=regexp:/etc/postfix/virtual_alias"
RUN postconf -e "transport_maps=regexp:/etc/postfix/transport"
RUN postconf -e "mydestination=planningalerts.org.au"

# Useful for testing SMTP server
# Example usage:
# swaks --to no-reply@planningalerts.org.au --server postfix:25
RUN apt-get install -y swaks

# Install nodejs for running maizzle
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
RUN apt-get install -y nodejs

# Install firefox for running some integration tests. Ubuntu's own firefox package only installs a snap, which
# doesn't work in Docker, so take the real package from the Mozilla team's PPA.
RUN apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository -y ppa:mozillateam/ppa \
    && apt-get update && apt-get install -y --no-install-recommends firefox-esr

# Needed for pg gem and bin/rails dbconsole
RUN apt-get install -y libpq-dev postgresql-client

# Install the fish shell
RUN apt-get install -y fish

USER deploy

COPY --chown=deploy:deploy Gemfile /app/Gemfile
COPY --chown=deploy:deploy Gemfile.lock /app/Gemfile.lock
RUN bundle install

ENTRYPOINT ["./.devcontainer/entrypoint.sh"]

CMD ["bin/rails", "server", "-p", "3000", "-b", "0.0.0.0"]

