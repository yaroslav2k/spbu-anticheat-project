ARG RUBY_VERSION=3.2.2

FROM ruby:${RUBY_VERSION}

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

