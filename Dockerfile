FROM hexpm/elixir:1.10.0-erlang-22.2.3-alpine-3.11.3 as build

# install build dependencies
RUN apk add --no-cache --update git

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
COPY rel rel
RUN mix release

# prepare release image
FROM alpine:3.11.3 AS app
RUN apk add --no-cache --update bash build-base coreutils curl docker gzip libffi-dev openssl openssl-dev python-dev py-pip tar tarsnap wget zip

RUN pip install --upgrade awscli gsutil

COPY etc/tarsnap.conf /etc/tarsnap/tarsnap.conf
COPY etc/boto /app/.boto

WORKDIR /app

COPY --from=build /app/_build/prod/rel/bob ./

ENV HOME=/app
