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

### HTTP support

To load HTTP support, require it by running:

```ruby
require 'bowser/http'
```

To make HTTP requests to your API, you can use `Bowser::HTTP.fetch`:

```ruby
Bowser::HTTP.fetch('/api/things')
```

It returns a [`Bowser::Promise`](https://github.com/clearwater-rb/bowser/blob/master/opal/bowser/promise.rb), on which you can call `then` or `catch` in order to execute a block of code based on success or failure, respectively.

```ruby
Bowser::HTTP.fetch(url)
  .then(&:json) # JSONify the response
  .then { |response| do_something_with(response.json) }
  .catch { |exception| warn exception.message }
```

To make `POST` requests, you can pass the `method` keyword argument. The body of the post is represented in the `data` keyword argument. This is in contrast to the ES6 `fetch` function, which uses `body`, but requires a string. The `data` argument lets you pass in a string or a hash, which will be converted to JSON:

```ruby
Bowser::HTTP.fetch(url, method: :post, data: { name: 'Bowser' })
```

## Contributing

This project is governed by a [Code of Conduct](CODE_OF_CONDUCT.md)

  1. Fork it
  1. Branch it
  1. Hack it
  1. Save it
  1. Commit it
  1. Push it
  1. Pull-request it
