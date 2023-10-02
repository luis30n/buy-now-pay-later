FROM ruby:3.2.2

ENV RAILS_ROOT /app

WORKDIR $RAILS_ROOT

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs netcat-openbsd  

COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install --jobs 4 --retry 3

COPY . .

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
