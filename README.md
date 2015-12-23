# Bowser

It's like `Browser`, but smaller. It provides minimal browser support for libraries and frameworks which don't need the full spectrum of support from [`opal-browser`](https://github.com/opal/opal-browser).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bowser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bowser

## Usage

Inside your front-end app:

```ruby
require 'bowser'

Bowser.document # Handle to the current document
Bowser.window   # Handle to the current window
```

### AJAX support

To make HTTP requests to your API, for example, you can do:

```ruby
Bowser::HTTP.fetch('/api/things')
```

It returns a `Promise`, which you can call `then`, `fail`, or `always` on in order to execute a block of code based on success, failure, or either one, respectively.

```ruby
Bowser::HTTP.fetch(url)
  .then { |response| do_something_with(response.json) }
  .fail { |exception| warn exception.message }
  .always { log "Fetched #{url}" }
```

The current implementation uses the `Promise` class from the Opal standard library, but it is not fully A+-compliant, so we're in the process of implementing our own.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

  1. Fork it
  1. Branch it
  1. Hack it
  1. Save it
  1. Commit it
  1. Push it
  1. Pull-request it
