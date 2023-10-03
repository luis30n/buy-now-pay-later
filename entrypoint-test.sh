#!/bin/bash

until nc -z -v -w30 db 5432
do
  echo "Waiting for database to be ready..."
  sleep 5
done

export DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL=true
echo 'Running migrations...'
bundle exec rake db:migrate
echo 'Running specs...'
bundle exec rspec

exec "$@"
