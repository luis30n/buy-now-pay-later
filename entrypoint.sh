#!/bin/bash

until nc -z -v -w30 db 5432
do
  echo "Waiting for database to be ready..."
  sleep 5
done

if [ "$DB_SETUP_ON_START" = "true" ]; then
  echo 'Running migrations...'
  bundle exec rake db:migrate
  echo 'Importing merchants from CSV...'
  bundle exec rake csv_import:merchants
  echo 'Importing orders from CSV...'
  bundle exec rake csv_import:orders
  echo 'Generating disbursements from past orders...'
  bundle exec rake disbursements:process_from_past_orders
fi

exec "$@"
