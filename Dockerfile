FROM ruby:3.2.2

COPY Gemfile* /tmp/
WORKDIR /tmp
RUN gem install bundler
RUN bundle install

ENV app /app
RUN mkdir $app
WORKDIR $app

# Copy the main application.
COPY . ./

CMD bundle exec puma -C config/puma.rb