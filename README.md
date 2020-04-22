# Vibes SDK - iOS

## Installation and Usage

For installation and integration instructions, see the [iOS SDK documentation][ios-docs].

## Contributing

### Install

### Development tools

Install [Xcode 8+][xcode], [ruby][ruby], and [homebrew][homebrew]. 

Then run `./bin/setup`

When adding new files to `Sources/` or `Tests/`, if you're not adding them using Xcode, you can run:

```bash
$ bin/sync-xcode
```

to sync the Xcode project's file references and build sources.

### Testing

Run specs using:

```bash
$ bin/test
```

#### Code Coverage

To generate code coverage, run `./bin/coverage`.

### Linting

To lint the code, run `./bin/lint`.

### Testing push notifications

There are a number of tools to help with this; [Pusher][pusher] is an excellent choice.

----

[xcode]: https://developer.apple.com/xcode/
[ruby]: https://www.ruby-lang.org/en/
[homebrew]: https://brew.sh/
[ios-docs]: https://developer.vibes.com/display/APIs/iOS+SDK+Documentation
[pusher]: https://github.com/noodlewerk/NWPusher
