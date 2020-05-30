FROM ruby:2.6.4

WORKDIR /myapp

RUN apt-get update && apt-get install -y curl gnupg

RUN apt-get -y update && \
      apt-get install --fix-missing --no-install-recommends -qq -y \
        build-essential \
        vim \
        wget gnupg \
        git-all \
        curl \
        ssh \
        postgresql-client\
        default-mysql-client libpq5 libpq-dev default-libmysqlclient-dev -y

# Copy the Gemfile and install the the RubyGems.
# This is a separate step so that bundle install wont run again unless Gemfile has changed
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Copying local always changes, therefore put it last
COPY . ./


ENV RAILS_ENV production

CMD bash script/start_web.sh


#FROM ruby:2.6.4
#
#RUN apt-get update \
#    && apt-get install -y --no-install-recommends \
#        nodejs postgresql-client redis-tools vim\
#    && rm -rf /var/lib/apt/lists/*
#
## Copy application files and install the bundle
#WORKDIR /usr/src/app
#COPY Gemfile* ./
#RUN gem install bundler:2.0.2
#RUN bundle install
#COPY . .
#
#
#EXPOSE 8080
#CMD ["bundle", "exec", "rackup", "--port=8080", "--env=production"]