FROM ruby:2.5.1
RUN apt-get update -qq && apt-get install -y nodejs \
    postgresql-client \
    locales \
    imagemagick && \
    localedef -i sv_SE -c -f UTF-8 -A /usr/share/locale/locale.alias sv_SE.UTF-8 && \
    mkdir /shf-project
ENV LANG sv_SE.UTF-8
WORKDIR /shf-project
COPY Gemfile* /shf-project/

RUN bundle install
COPY . /shf-project

