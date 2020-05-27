#FROM ruby:2.6.4
#
#RUN apt-get update -qq && \
# apt-get install -y  vim \
# wget gnupg \
# git-all \
# curl \
# ssh \
# nodejs postgresql-client
#RUN mkdir /myapp
#WORKDIR /myapp
#COPY Gemfile /myapp/Gemfile
#COPY Gemfile.lock /myapp/Gemfile.lock
#RUN gem install bundler:2.0.2
#RUN bundle install
#COPY . /myapp
#
## Add a script to be executed every time the container starts.
#COPY entrypoint.sh /usr/bin/
#RUN chmod +x /usr/bin/entrypoint.sh
#ENTRYPOINT ["entrypoint.sh"]
#EXPOSE 3000
#
#RUN echo "in prod"
#
## Pre-compile assets
#RUN EDITOR="mate --wait" bundle exec rails credentials:edit

ENV RAILS_ENV production
FROM ruby:2.6.4

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy application files and install the bundle
WORKDIR /usr/src/app
COPY Gemfile* ./
RUN gem install bundler:2.0.2
RUN bundle install
COPY . .


EXPOSE 8080
CMD ["bundle", "exec", "rackup", "--port=8080", "--env=production"]