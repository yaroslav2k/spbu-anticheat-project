ARG RUBY_VERSION=3.0.0

FROM ruby:${RUBY_VERSION}

WORKDIR /app
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

COPY . .

EXPOSE 3000


ENTRYPOINT ["/bin/bash", "-c"]
CMD ["rails", "server"]
