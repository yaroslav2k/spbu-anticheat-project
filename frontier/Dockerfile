ARG RUBY_VERSION=3.3.0

FROM ruby:${RUBY_VERSION}

RUN apt-get update && apt-get -y install --no-install-recommends less && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

COPY . .

ENV RAILS_ENV=production

RUN bundle exec rails assets:precompile

EXPOSE 3000

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["rails", "server"]

