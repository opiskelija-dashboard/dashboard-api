# README

[![Coverage Status](https://coveralls.io/repos/github/opiskelija-dashboard/dashboard-api/badge.svg?branch=master)](https://coveralls.io/github/opiskelija-dashboard/dashboard-api?branch=master)
[![Build Status](https://travis-ci.org/opiskelija-dashboard/dashboard-api.svg?branch=master)](https://travis-ci.org/opiskelija-dashboard/dashboard-api)

API for getting student points from the [TMC API](https://github.com/testmycode/tmc-server/), and passing them on to the [dashboard frontend](https://github.com/opiskelija-dashboard/dashboard).
* Ruby version 2.3.1, Rails v5.0.4

## How to set it up

TODO: more detail, but essentially this:

 * download to a server
 * `bundle install`
 * check conf settings in `config/application.rb` and `config/environments/production.rb`
 * `bin/rails db:migrate`
 * `bin/rails db:seed`
 * `bin/rails server`

## How it works

See [the main documentation](docs/documentation.md).

Maybe this picture is of use:

    ╔═══════════════╗                              ╔════════════╗
    ║               ║                              ║            ║
    ║  Course page  ║◁────────────────────────────▷║ TMC server ║
    ║               ║                              ║            ║
    ║               ║                              ╚════════════╝
    ║ ┏━━━━━━━━━━━┓═╝        ╔══════════════╗            △
    ║ ┃ Dashboard ┃          ║   Backend    ║            │
    ║ ┃ frontend  ┃◁────────▷║(this project)║◁───────────┘
    ║ ┗━━━━━━━━━━━┛═╗        ║              ║
    ╚═══════════════╝        ╚══════════════╝
