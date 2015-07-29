[![Build Status](https://travis-ci.org/rosette-proj/rosette-server-github.svg)](https://travis-ci.org/rosette-proj/rosette-server-github) [![Code Climate](https://codeclimate.com/github/rosette-proj/rosette-server-github/badges/gpa.svg)](https://codeclimate.com/github/rosette-proj/rosette-server-github) [![Test Coverage](https://codeclimate.com/github/rosette-proj/rosette-extractor-json/badges/coverage.svg)](https://codeclimate.com/github/rosette-proj/rosette-server-github/coverage)

rosette-server-github
====================

Provides a github webhook that enqueues new commits on the configured Rosette queue. You can configure github to notify you whenever anyone pushes to your repo. A running instance of rosette-server-github can authenticate the request and enqueue the commits.

## Installation

`gem install rosette-server-github`

Then, somewhere in your project:

```ruby
require 'rosette/server/github'
```

### Introduction

This library is generally meant to be used with the Rosette internationalization platform that extracts translatable phrases from git repositories.

### Usage with rosette-server

Let's assume you're configuring an instance of [`Rosette::Server`](https://github.com/rosette-proj/rosette-server). Adding github push support would cause your configuration to look something like this:

```ruby
# config.ru
require 'rosette/core'
require 'rosette/server'
require 'rosette/server/github'

rosette_config = Rosette.build_config do |config|
  # your config here
end

server = Rosette::Server::ApiV1.new(rosette_config)

github_server = Rosette::Server::Github.new(rosette_config, {
  github_webhook_secret: ENV['GITHUB_WEBHOOK_SECRET']
})

builder = Rosette::Server::Builder.new
builder.mount('/', api_server)
builder.mount('/github', github_server)

run builder.to_app
```

You can then add a "push" hook to your repo's settings in Github that sends requests to http://your-website.com/github/push.json.
```

## Requirements

This project must be run under jRuby. It uses [expert](https://github.com/camertron/expert) to manage java dependencies via Maven. Run `bundle exec expert install` in the project root to download and install java dependencies.

## Running Tests

`bundle exec rake` or `bundle exec rspec` should do the trick.

## Authors

* Cameron C. Dutro: http://github.com/camertron
