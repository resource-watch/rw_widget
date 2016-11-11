# Resource Watch Widget Service

[![Build Status](https://travis-ci.org/resource-watch/rw_widget.svg?branch=staging)](https://travis-ci.org/resource-watch/rw_widget) [![Code Climate](https://codeclimate.com/github/resource-watch/rw_widget/badges/gpa.svg)](https://codeclimate.com/github/resource-watch/rw_widget)

TODO: Write a project description

## Installation

Requirements:

* Ruby 2.3.1 [How to install](https://gorails.com/setup/osx/10.10-yosemite)
* PostgreSQL 9.4+ [How to install](http://exponential.io/blog/2015/02/21/install-postgresql-on-mac-os-x-via-brew/)

Install global dependencies:

    gem install bundler

Install project dependencies:

    bundle install

## Usage

First time execute:

    cp config/database.yml.sample config/database.yml

    bundle exec rake db:create
    bundle exec rake db:migrate

To run application:

    bundle exec rails server

## TEST

  Run rspec:

    bin/rspec

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b feature/my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/my-new-feature`
5. Submit a pull request :D

### BEFORE CREATING A PULL REQUEST

  Please check all of [these points](https://github.com/resource-watch/rw_widget/blob/master/CONTRIBUTING.md).

