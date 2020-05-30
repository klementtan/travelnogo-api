#!/bin/bash -e

if [[ -a /tmp/puma.pid ]]; then
  rm /tmp/puma.pid
fi

if [[ $RAILS_ENV == "production" ]]; then
  echo "in prod"
  EDITOR="mate --wait" bundle exec rails credentials:edit
fi

