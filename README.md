![Logo](https://raw.githubusercontent.com/samvera-labs/sufia.io/gh-pages/assets/images/sufia_logo_white_bg_small.png)

Code: [![Version](https://badge.fury.io/rb/sufia.png)](http://badge.fury.io/rb/sufia)
[![Build Status](https://travis-ci.org/samvera/sufia.png?branch=master)](https://travis-ci.org/samvera/sufia)
[![Coverage Status](https://coveralls.io/repos/github/samvera/sufia/badge.svg?branch=master)](https://coveralls.io/github/samvera/sufia?branch=master)
[![Code Climate](https://codeclimate.com/github/samvera/sufia/badges/gpa.svg)](https://codeclimate.com/github/samvera/sufia)
[![Dependency Update Status](https://gemnasium.com/samvera/sufia.png)](https://gemnasium.com/samvera/sufia)
[![Dependency Maintenance Status](https://dependencyci.com/github/samvera/sufia/badge)](https://dependencyci.com/github/samvera/sufia)

Docs: [![Documentation Status](https://inch-ci.org/github/samvera/sufia.svg?branch=master)](https://inch-ci.org/github/samvera/sufia)
[![API Docs](http://img.shields.io/badge/API-docs-blue.svg)](http://rubydoc.info/gems/sufia)
[![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./.github/CONTRIBUTING.md)
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)

Jump in: [![Slack Status](http://slack.samvera.org/badge.svg)](http://slack.samvera.org/)
[![Ready Tickets](https://badge.waffle.io/samvera/sufia.png?label=ready&title=Ready)](https://waffle.io/samvera/sufia)


# Shift in Community Focus

During 2017, the [Samvera community](http://samvera.org/) consolidated Sufia and [CurationConcerns](https://github.com/samvera/curation_concerns) into [Hyrax](https://github.com/samvera/hyrax):

* [planning notes on consolidation](https://wiki.duraspace.org/pages/viewpage.action?pageId=78161232))
* [release notes on the bridge of Sufia to Hyrax](https://github.com/samvera/hyrax/releases/tag/v1.0.0)
* [release notes on the bridge of CurationConcerns to Hyrax](https://github.com/samvera/hyrax/releases/tag/v2.0.0)
* [Samvera documentation for developers and managers](https://samvera.github.io)

The Samvera Community effort has shifted its attention to developing out Hyrax.

<hr>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

# Table of Contents

  * [What is Sufia?](#what-is-sufia)
    * [Feature list](#feature-list)
  * [Help](#help)
  * [Getting started](#getting-started)
    * [Prerequisites](#prerequisites)
      * [Characterization](#characterization)
      * [Derivatives](#derivatives)
    * [Environments](#environments)
    * [Ruby](#ruby)
    * [Redis](#redis)
    * [Rails](#rails)
  * [Creating a Sufia\-based app](#creating-a-sufia-based-app)
    * [Generate a primary work type](#generate-a-primary-work-type)
    * [Start servers](#start-servers)
    * [Add Default Admin Set](#add-default-admin-set)
  * [Managing a Sufia\-based app](#managing-a-sufia-based-app)
  * [License](#license)
  * [Contributing](#contributing)
  * [Development](#development)
  * [Release process](#release-process)
  * [Acknowledgments](#acknowledgments)

# What is Sufia?

Sufia uses the full power of [Samvera](http://samvera.org/) and extends it to provide a user interface around common repository features and social features (see below). Sufia offers self-deposit and proxy deposit workflows, and mediated deposit workflows are being developed in a community sprint running from September-December 2016. Sufia delivers its rich and growing set of features via a modern, responsive user interface. It is implemented as a Rails engine, so it is meant to be added to existing Rails apps.

## Feature list

Sufia has many features. [Read more about what they are and how to turn them on](https://github.com/samvera/sufia/wiki/Feature-matrix). See the [Sufia Management Guide](https://github.com/samvera/sufia/wiki/Sufia-Management-Guide) to learn more.

For non-technical documentation about Sufia, see its [documentation site](http://sufia.io/).

# Help

If you have questions or need help, please email [the Samvera community tech list](mailto:samvera-tech@googlegroups.com) or stop by the #dev channel in [the Samvera community Slack team](https://wiki.duraspace.org/pages/viewpage.action?pageId=43910187#Getintouch!-Slack).

# Getting started

This document contains instructions specific to setting up an app with __Sufia
v7.4.1__. If you are looking for instructions on installing a different
version, be sure to select the appropriate branch or tag from the drop-down
menu above.

Prerequisites are required for both Creating a Sufia\-based app and Contributing new features to Sufia.
After installing the Prerequisites:
 * If you would like to create a new application using Sufia follow the instructions for [Creating a Sufia\-based app](#creating-a-sufia-based-app).
 * If you would like to create new features for Sufia follow the instructions for [Contributing](#contributing) and [Development](#development).

## Prerequisites

Sufia 7 requires the following software to work:

1. [Solr](http://lucene.apache.org/solr/) version >= 5.x (tested up to 6.4.1)
1. [Fedora Commons](http://www.fedora-commons.org/) digital repository version >= 4.5.1 (tested up to 4.7.1)
1. A SQL RDBMS (MySQL, PostgreSQL), though **note** that SQLite will be used by default if you're looking to get up and running quickly
1. [Redis](http://redis.io/), a key-value store
1. [ImageMagick](http://www.imagemagick.org/) with JPEG-2000 support
1. [FITS](#characterization) version 0.8.x (0.8.5 is known to be good)
1. [LibreOffice](#derivatives)

**NOTE: The [Sufia Development Guide](https://github.com/samvera/sufia/wiki/Sufia-Development-Guide) has instructions for installing Solr and Fedora in a development environment.**

### Characterization

1. Go to http://projects.iq.harvard.edu/fits/downloads and download a copy of FITS (see above to pick a known working version) & unpack it somewhere on your machine.
1. Mark fits.sh as executable: `chmod a+x fits.sh`
1. Run `fits.sh -h` from the command line and see a help message to ensure FITS is properly installed
1. Give your Sufia app access to FITS by:
    1. Adding the full fits.sh path to your PATH (e.g., in your .bash_profile), **OR**
    1. Changing `config/initializers/sufia.rb` to point to your FITS location:  `config.fits_path = "/<your full path>/fits.sh"`

### Derivatives

Install [LibreOffice](https://www.libreoffice.org/). If `which soffice` returns a path, you're done. Otherwise, add the full path to soffice to your PATH (in your `.bash_profile`, for instance). On OSX, soffice is **inside** LibreOffice.app. Your path may look like "/<your full path to>/LibreOffice.app/Contents/MacOS/"

You may also require [ghostscript](http://www.ghostscript.com/) if it does not come with your compiled version LibreOffice. `brew install ghostscript` should resolve the dependency on a mac.

**NOTE**: derivatives are served from the filesystem in Sufia 7, which is a difference from earlier versions of Sufia.

## Environments

Note here that the following commands assume you're setting up Sufia in a development environment (using the Rails built-in development environment). If you're setting up a production or production-like environment, you may wish to tell Rails that by prepending `RAILS_ENV=production` to the commands that follow, e.g., `rails`, `rake`, `bundle`, and so on.

## Ruby

First, you'll need a working Ruby installation. You can install this via your operating system's package manager -- you are likely to get farther with OSX, Linux, or UNIX than Windows but your mileage may vary -- but we recommend using a Ruby version manager such as [RVM](https://rvm.io/) or [rbenv](https://github.com/sstephenson/rbenv).

We recommend either Ruby 2.3 or the latest 2.2 version.

## Redis

[Redis](http://redis.io/) is a key-value store that Sufia uses to provide activity streams on repository objects and users, and to prevent race conditions as a global mutex when modifying order-persisting objects.

Starting up Redis will depend on your operating system, and may in fact already be started on your system. You may want to consult the [Redis documentation](http://redis.io/documentation) for help doing this.

## Rails
We recommend the latest Rails 5.0 release.

```
# If you don't already have Rails at your disposal...
gem install rails -v 5.0.1
```

# Creating a Sufia-based app

Generate a new Rails application using the template.

```
rails new my_app -m https://raw.githubusercontent.com/samvera/sufia/master/template.rb
```

Generating a new Rails application using Sufia's template above takes cares of a number of steps for you, including:

* Adding Sufia (and any of its dependencies) to your application `Gemfile`, to declare that Sufia is a dependency of your application
* Running `bundle install`, to install Sufia and its dependencies
* Running Sufia's install generator, to add a number of files that Sufia requires within your Rails app, including e.g. database migrations
* Loading all of Sufia's database migrations into your application's database
* Loading Sufia's default workflows into your application's database

## Generate a work type

While earlier versions of Sufia came with a pre-defined object model, Sufia 7 allows you to generate an arbitrary number of work types. Let's start by generating one.

Pass a (CamelCased) model name to Sufia's work generator to get started, e.g.:

```
rails generate sufia:work Work
```

or

```
rails generate sufia:work MovingImage
```

## Start servers

To test-drive your new Sufia application in development mode, spin up the servers that Sufia needs (Solr, Fedora, and Rails):

```
rake hydra:server
```

And now you should be able to browse to [localhost:3000](http://localhost:3000/) and see the application. Note that this web server is purely for development purposes; you will want to use a more fully featured [web server](https://github.com/samvera/sufia/wiki/Sufia-Management-Guide#web-server) for production-like environments.

## Add Default Admin Set

After Fedora and Solr are running, create the default administrative set by running the following rake task:

```
rake sufia:default_admin_set:create
```

You will want to run this command the first time this code is deployed to a new environment as well. Note it depends on loading workflows, which is run by the install template but also needs to be run in a new environment:

```
rake curation_concerns:workflow:load
```

# Managing a Sufia-based app

The [Sufia Management Guide](https://github.com/samvera/sufia/wiki/Sufia-Management-Guide) provides tips for how to manage, customize, and enhance your Sufia application, including guidance specific to:

* Production implementations
* Configuration of background workers
* Integration with e.g., Dropbox, Google Analytics, and Zotero
* Audiovisual transcoding with `ffmpeg`
* Setting up administrative users
* Metadata customization

# License

Sufia is available under [the Apache 2.0 license](LICENSE.md).

# Contributing

We'd love to accept your contributions.  Please see our guide to [contributing to Sufia](./.github/CONTRIBUTING.md).

If you'd like to help the development effort and you're not sure where to get started, you can always grab a ticket in the "Ready" column from our [Waffle board](https://waffle.io/samvera/sufia). There are other ways to help, too.

* [Contribute a user story](https://github.com/samvera/sufia/issues/new).
* Help us improve [Sufia's test coverage](https://coveralls.io/r/samvera/sufia) or [documentation coverage](https://inch-ci.org/github/samvera/sufia).
* Refactor away [code smells](https://codeclimate.com/github/samvera/sufia).

# Development

The [Sufia Development Guide](https://github.com/samvera/sufia/wiki/Sufia-Development-Guide) is for people who want to modify Sufia itself, not an application that uses Sufia.

# Release process

See the [release management process](https://github.com/samvera/sufia/wiki/Release-management-process).

# Acknowledgments

This software has been developed by and is brought to you by the Samvera community.  Learn more at the
[Samvera website](http://samvera.org/).

![Samvera Logo](http://sufia.io/assets/images/samvera_logo.png)

The Sufia logo uses the Hong Kong Hustle font, thanks to [Iconian's](http://www.iconian.com/) non-commercial use policy.
