## Version 0.5.4

- Improve ServiceWorker promise support
- Add support for `Document#head`
- Add `Iterable` mixin to support JS Iterable interface
  - Allows you to `include Iterable` on any JS iterable to make it `Enumerable`
- Add initial Canvas support

## Version 0.5.3

- Add default `initialize` for `DelegateNative`
- Return `nil` from `DelegateNative` methods that explicitly return `undefined`
  - Previously, this would raise `NoMethodError`
- Yield timestamp to `Bowser.window.animation_frame` block

## Version 0.5.2

- Allow videos to be full-screened

## Version 0.5.1

This appears to have been an accidental release. I actually don't know what happened here.

## Version 0.5.0

- IndexedDB support (#22)
- ServiceWorker support (#5)
- Subscript operators (`[]` and `[]=`) to get/set HTML attributes on `Element`
- Added `HTTP::Response#ok?` to align with [`Response.ok`](https://developer.mozilla.org/en-US/docs/Web/API/Response/ok)

## Version 0.3.0

- Fix bug with falsy JS values as element properties
- Yield request object in `HTTP` methods (like `.fetch` and `.upload`)
- Two `Element` instances holding the same native element are equal (`==`)
- Fix travis + phantomjs 2
- Add request upload object
- Add Geolocation support

## Version 0.2.2

- Use event.target instead of event.currentTarget for native events
- Fix spec failure with a more recent `opal-rspec`
- Remove opal-rspec version restriction
- Improve native pass-through in Event
- Allow WebSockets to be closed

## Version 0.2.1

- Allow passing data, headers, and method with HTTP.fetch
- Allow WebSockets to reconnect automatically with configurable delay
- Relax Opal version restriction

## Version 0.2.0

- Allow specifying methods for HTTP requests, including file uploads
- Add `Element#to_n` and `Event#to_n` to unwrap the native objects
- Make HTTP events just use `Bowser::Event` instead of their own type
- Proxy all native element/event properties
  - This provides the following types of translations from Ruby method names to JS property names:
    - `element.text_content` in Ruby becomes `element.textContent` in JS
    - Predicates like `element.content_editable?` checks for `contentEditable` and `isContentEditable` properties, preferring the version without `is` if both exist.
    - If the property is a function, it gets called.
    - No wrapping of results is done for proxied properties. You get the raw JS value back.
- Add `Element#children` to wrap child nodes in `Bowser::Element` objects
- Add `Bowser.window.location.hash`
- Add `Bowser.window.has_push_state?`
- Use `load` event for `Bowser::HTTP::Request` instead of `success`. It was causing problems and `load` is the canonical event to use.

## Version 0.1.5

- Fix `animation_frame` polyfill delay
- Add the abillity to upload files directly from file input elements
  - Allowing this instead of reading the files in first is a HUGE memory savings for large files. It uses the browser's internal streaming capabilities so we don't need to load the full file into memory.
- Memoize file read data

## Version 0.1.4

- Relax Opal version restriction to 0.8-0.11
- Add `Bowser::HTTP::Response#text` to get the raw response body instead of assuming JSON
- Fix JSON dependency loading instead of assuming it's there

## Version 0.1.3

- Add `Event#stop_propagation`
- Add first-class support for `file` input fields

## Version 0.1.2

- Add `Bowser::Window::Location#href`
- Fix missing element check for `Document#[]`

## Version 0.1.1

- Add `Window#scroll`
- Add `Window::History#push`
- Add WebSocket support

## Version 0.1.0

- Initial release
