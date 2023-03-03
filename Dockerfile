FROM ruby:2.7.2-slim-buster

ENV LANG C.UTF-8

ENV BUILD_PACKAGES="curl bash zlib1g-dev liblzma-dev patch build-essential ruby-dev libpq-dev apt-utils git" \
    DEV_PACKAGES="tzdata postgresql-client-common ruby-nokogiri ripgrep" \
    RUBY_PACKAGES="nodejs yarn"

RUN apt-get -y update && \
    apt-get -y install $BUILD_PACKAGES \
    $DEV_PACKAGES && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get update && apt-get install -y $RUBY_PACKAGES && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

ARG RAILS_ENV
ENV RAILS_ENV ${RAILS_ENV}

ARG NODE_ENV
ENV NODE_ENV ${NODE_ENV}

ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE ${SECRET_KEY_BASE}

ARG RAILS_ENV
ENV RAILS_ENV ${RAILS_ENV}
RUN echo $RAILS_ENV

ARG NODE_ENV
ENV NODE_ENV ${NODE_ENV}

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
# RUN gem install bundler:2.1.4
RUN bundle install

ADD package* yarn* $APP_HOME/
RUN yarn install --ignore-engines && yarn cache clean

COPY . .

RUN mkdir -p tmp/pids
RUN node -v

CMD ["bundle", "exec", "puma"]
