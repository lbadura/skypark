FROM ruby:2.4.0

RUN apt-get update -qq && apt-get install -y build-essential
ENV APP_ROOT /var/www/skypark
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT
ADD Gemfile* $APP_ROOT/
RUN gem install bundler
RUN bundle install
ADD . $APP_ROOT
EXPOSE 80
CMD ["bundle", "install"]
CMD ["rackup", "-o", "0.0.0.0", "-p", "80"]
