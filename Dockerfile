FROM ruby:2.3.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /sprint_board
WORKDIR /sprint_board
ADD Gemfile /sprint_board/Gemfile
ADD Gemfile.lock /sprint_board/Gemfile.lock
RUN bundle install
ADD . /sprint_board