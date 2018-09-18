# Quick Start Guide

This guide will walk you through creating a minimal Turbolinks for RubyMotion application.

We’ll use the demo app’s bundled server in our examples, which runs at `http://localhost:9292/`, but you can adjust the URL and hostname below to point to your own application. See [Running the Demo](README.md#running-the-demo) for instructions on starting the demo server.

Note that for the sake of brevity, these examples use a `UINavigationController` and implement everything inside the `AppDelegate`. In a real application, you may not want to use a navigation controller, and you should consider factoring these responsibilities out of the `AppDelegate` and into separate classes.

In this tutorial, we will create an iOS application.

## 1. Create a RubyMotion iOS project

Create a new iOS project using the RubyMotion generator.

    motion create turbolinks_demo_app

Next, add the `motion-turbolinks` gem to your app's `Gemfile`:

```ruby
gem 'motion-turbolinks', github: 'andrewhavens/motion-turbolinks'
```

Then run `bundle install`.

Next, open the app's `app/app_delegate.rb` file and replace it with the following to create a `UINavigationController` and make it the window’s root view controller:

```ruby
class AppDelegate
  def application(application, didFinishLaunchingWithOptions: launchOptions)
    @navigationController = UINavigationController.alloc.init

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @navigationController
    @window.makeKeyAndVisible

    true
  end
end
```

▶️ Build and run the app in the simulator to make sure it works. It won’t do anything interesting, but it should run without error.

    $ bundle exec rake

## 2. Configure your project for Turbolinks

**Configure NSAppTransportSecurity for the demo server.** By default, iOS versions 9 and later restrict access to unencrypted HTTP connections. In order for your application to connect to the demo server, you must configure it to allow insecure HTTP requests to `localhost`.

Open your app's `Rakefile` and change your app configuration to include an exception:

```ruby
Motion::Project::App.setup do |app|
  app.name = 'turbolinks_demo_app'
  app.info_plist['NSExceptionDomains'] = {
    'localhost' => { 'NSExceptionAllowsInsecureHTTPLoads' => true }
  }
end
```

See [Apple’s property list documentation](https://developer.apple.com/library/prerelease/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33) for more information about NSAppTransportSecurity.

## 3. Set up a Turbolinks Session and perform an initial visit

A Turbolinks Session manages a WKWebView instance and moves it between Visitable view controllers when you navigate. Your application is responsible for displaying a Visitable view controller, giving it a URL, and telling the Session to visit it. See [Understanding Turbolinks Concepts](README.md#understanding-turbolinks-concepts) for details.

In your AppDelegate, initialize a `Turbolinks::Session`. Then, create a VisitableViewController with the demo server’s URL, and push it onto the navigation stack. Finally, call `session.visit()` with your view controller to perform the visit.

```ruby
class AppDelegate
  def application(application, didFinishLaunchingWithOptions: launchOptions)
    @navigationController = UINavigationController.alloc.init

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @navigationController
    @window.makeKeyAndVisible

    @session = Turbolinks::Session.new
    visit "http://localhost:9292"

    true
  end

  def visit(url)
    view_controller = Turbolinks::VisitableViewController.new(url: url)
    @navigationController.pushViewController(view_controller, animated: true)
    @session.visit(view_controller)
  end
end
```

▶️ Ensure the Turbolinks demo server is running:

    $ turbolinks_demo_server

▶️ In a separate tab, build and run the application in the simulator.

    $ bundle exec rake

The demo page should load, but tapping a link will have no effect. To handle link taps and initiate a Turbolinks visit, you must configure the Session’s delegate.

## 4. Configure the Session’s delegate

The Session notifies its delegate by proposing a visit whenever you tap a link. It also notifies its delegate when a visit request fails. The Session’s delegate is responsible for handling these events and deciding how to proceed. See [Creating a Session](README.md#creating-a-session) for details.

First, assign the Session’s `delegate` property. For demonstration purposes, we’ll make AppDelegate the Session’s delegate.

```ruby
class AppDelegate
  def application(application, didFinishLaunchingWithOptions: launchOptions)
    # ...
    @session = Turbolinks::Session.new
    @session.delegate = self
    visit "http://localhost:9292"
    # ...
  end
  # ...
end
```

Next, implement the SessionDelegate protocol by adding these methods to the AppDelegate:

```ruby
class AppDelegate
  # ...
  def session(session, didProposeVisitToURL: url, withAction: action)
    visit(url)
  end

  def session(session, didFailRequestForVisitable: visitable, withError: error)
    alert = UIAlertController.alertControllerWithTitle("Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyleAlert)
    alert.addAction(UIAlertAction.actionWithTitle("OK", style: UIAlertActionStyleDefault, handler: nil))
    @navigationController.presentViewController(alert, animated: true, completion: nil)
  end
end
```

We handle a proposed visit in the same way as the initial visit: by creating a VisitableViewController, pushing it onto the navigation stack, and visiting it with the Session. Since it works the same way, we can reuse the `visit` method that we defined earlier. When a visit request fails, we display an alert.

▶️ Build the app and run it in the simulator. Congratulations! Tapping a link should now work.

## 5. Read the documentation

A real application will want to customize the view controller, respond to different visit actions, and gracefully handle errors. See [Building Your Turbolinks Application](README.md#building-your-turbolinks-application) for detailed instructions.
