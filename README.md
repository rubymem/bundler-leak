# bundler-leak

* [Homepage](https://github.com/rubymem/bundler-leak#readme)
* [Issues](https://github.com/rubymem/bundler-leak/issues)
* [Documentation](http://rubydoc.info/gems/bundler-leak/frames)
* [Email](mailto:oss at ombulabs.com)
* [![Build Status](https://travis-ci.org/rubymem/bundler-leak.svg?branch=master)](https://travis-ci.org/rubymem/bundler-leak)
* [![Code Climate](https://codeclimate.com/github/rubymem/bundler-leak.svg)](https://codeclimate.com/github/rubymem/bundler-leak)

## Description

The best tool to find leaky gems in your dependencies. Make sure memory leaks
are not in your gem dependencies.

## Features

* Checks for memory leaks of gems in `Gemfile.lock`
* Prints memory leak information

## Synopsis

Audit a project's `Gemfile.lock`:

```shell
    $ bundle leak

    Name: celluloid
    Version: 0.17.0
    URL: https://github.com/celluloid/celluloid/issues/670
    Title: Memory Leak using Celluloid::Future
    Solution: remove or disable this gem until a patch is available!

    Name: therubyracer
    Version: 0.12.1
    URL: https://github.com/cowboyd/therubyracer/pull/336
    Title: Memory leak in WeakValueMap
    Solution: upgrade to ~> 0.12.3

    Unpatched versions found!
```

Update the [ruby-mem-advisory-db] that `bundle leak` uses:

```shell
    $ bundle leak update

    cd data/ruby-mem-advisory-db
    git pull origin master
    remote: Enumerating objects: 14, done.
    remote: Counting objects: 100% (14/14), done.
    remote: Compressing objects: 100% (4/4), done.
    remote: Total 9 (delta 5), reused 7 (delta 4), pack-reused 0
    Unpacking objects: 100% (9/9), done.
    From github.com:rubymem/ruby-mem-advisory-db
     * branch            master     -> FETCH_HEAD
       3254525..c4fc78e  master     -> origin/master
    Updating 3254525..c4fc78e
    Fast-forward
     README.md                 | 68 ++++++++++++++++++++------------------------------------------------
     gems/therubyracer/336.yml |  4 ++++
     2 files changed, 24 insertions(+), 48 deletions(-)
```

Update the [ruby-mem-advisory-db] and check `Gemfile.lock` (useful for CI runs):

    $ bundle leak check --update

Rake task:

```ruby
require 'bundler/plumber/task'
Bundler::Plumber::Task.new

task default: 'bundle:leak'
```

## Requirements

* [ruby] >= 1.9.3
* [rubygems] >= 1.8
* [thor] ~> 0.18
* [bundler] ~> 1.2

## Install

    $ gem install bundler-leak

## Contributing

1. Clone the repo
1. `./bin/setup` # To populate data dir.
1. `bundle exec rake`

## License

Copyright (c) 2019 OmbuLabs (hello at ombulabs.com)

Copyright (c) 2013-2016 Hal Brodigan (postmodern.mod3 at gmail.com)

bundler-leak is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

bundler-leak is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with bundler-leak.  If not, see <http://www.gnu.org/licenses/>.

[ruby]: https://ruby-lang.org
[rubygems]: https://rubygems.org
[thor]: http://whatisthor.com/
[bundler]: https://github.com/carlhuda/bundler#readme

[ruby-mem-advisory-db]: https://github.com/rubymem/ruby-mem-advisory-db
