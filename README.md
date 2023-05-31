# Turbo Native iOS for RubyMotion

**Build high-fidelity hybrid apps with native navigation and a single shared web view.** Turbo Native iOS for RubyMotion provides the tooling to wrap your [Turbo 7](https://github.com/hotwired/turbo)-enabled web app in a native iOS shell. It manages a single WKWebView instance across multiple view controllers, giving you native navigation UI with all the client-side performance benefits of Turbo.

## Features

- **Deliver fast, efficient hybrid apps.** Avoid reloading JavaScript and CSS. Save memory by sharing one WKWebView.
- **Reuse mobile web views across platforms.** Create your views once, on the server, in HTML. Deploy them to iOS, [Android](https://github.com/hotwired/turbo-android), and mobile browsers simultaneously. Ship new features without waiting on App Store approval.
- **Enhance web views with native UI.** Navigate web views using native patterns. Augment web UI with native controls.
- **Produce large apps with small teams.** Achieve baseline HTML coverage for free. Upgrade to native views as needed.

### Features of Turbo Native iOS for RubyMotion

- **Ruby syntax. Native performance.** Build native iOS and Android apps using the Ruby syntax you know and love with the same performance as Swift and Java by using [RubyMotion](http://www.rubymotion.com/).

## Requirements

Turbo Native iOS for RubyMotion is compatible with all versions of RubyMotion.

**Note:** You should understand how Turbo works with web applications in the browser before attempting to use Turbo iOS. See the [Turbo 7 documentation](https://github.com/hotwired/turbo) for details. Ensure that your web app sets the `window.Turbo` global variable as it's required by the native apps:

```javascript
import { Turbo } from "@hotwired/turbo-rails"
window.Turbo = Turbo
```

## Getting Started

The best way to get started with Turbo iOS to try out the demo app first to get familiar with the framework. The demo app walks you through all the basic Turbo flows as well as some advanced features. To run the demo, clone this repo and open `Demo/Demo.xcworkspace` in Xcode and run the Demo target. See [Demo/README.md](Demo/README.md) for more details about the demo. When you’re ready to start your own application, read through the rest of the documentation.

## Documentation

- [Quick Start](docs/QuickStartGuide.md)

## Contributing

Turbo iOS is open-source software, freely distributable under the terms of an [MIT-style license](LICENSE). The [source code is hosted on GitHub](https://github.com/hotwired/turbo-ios).
Development is sponsored by [Basecamp](https://basecamp.com/).

We welcome contributions in the form of bug reports, pull requests, or thoughtful discussions in the [GitHub issue tracker](https://github.com/hotwired/turbo-ios/issues).

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

---

© 2020 Basecamp, LLC


