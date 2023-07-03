# Quick Start Guide

This is a quick start guide to creating the most minimal Turbo iOS application from scratch get up and running in a few minutes. This will support basic back/forward navigation, but will not be a fully functional application.

1. First, create a new RubyMotion app

Run 

```bash
$ motion create quick --template=ios
```

2. Add the `motion-turbo-ios` dependency. Add this line to your application's Gemfile:

```ruby
gem 'motion-turbo-ios', path: '/Users/petrik/Projects/All/_gems/motion-turbo-ios'
gem 'ib', git: 'https://github.com/rubymotion-community/ib.git'
```

And then execute:

```bash
$ bundle
```

3. Open the `app/app_delegate.rb`, and replace the entire file with this code:

```ruby
class AppDelegate
  def application(application, didFinishLaunchingWithOptions: options)
    true
  end

  def application(application, configurationForConnectingSceneSession: connectingSceneSession, options: options)
    # TODO options ||= UIScene.ConnectionOptions
    UISceneConfiguration.alloc.initWithName("Default Configuration", sessionRole: connectingSceneSession.role)
  end

  def application(application, didDiscardSceneSessions: sceneSessions)
  end
end
```

4. Create `app/scene_delegate.rb`, and replace the entire file with this code:

```ruby
class SceneDelegate < UIResponder

  include Turbo::Session::SessionDelegateMethods

  attr_accessor :window

  def scene(scene, willConnectToSession: session, options: options)
    return unless scene.is_a?(UIWindowScene)
    window.rootViewController = navigationController if window
    visit(NSURL.alloc.initWithString("https://turbo-native-demo.glitch.me"))
  end

  def visit(url)
    viewController = Turbo::VisitableViewController.alloc.initWithURL(url)
    navigationController.pushViewController(viewController, animated: true)
    session.visitVisitable(viewController)
  end

  ## SessionDelegate

  def session(session, didProposeVisitProsal: proposal)
    visit(proposal.url)
  end

  def session(session, didFailRequestForVisitable: visitable, withError: error)
    puts "didFailRequestForVisitable: #{error}"
  end

  def sessionWebViewProcessDidTerminate(session)
    session.reload
  end

  private

  def navigationController
    @navigationController ||= UINavigationController.new
  end

  def session
    @session ||=begin
      session = Turbo::Session.alloc.init
      session.delegate = self
      session
    end
  end
end
```

5. Create `app/view_controller.rb`, and replace the entire file with this code:

```ruby
class ViewController < UIViewController
  def viewDidLoad
    super
    # Do any additional setup after loading the view.
 end
end
```

6. Create `resources/LaunchScreen.storyboard`, and replace the entire file with this code:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="13122.16" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES" initialViewController="01J-lp-oVM">
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="13104.12"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <scenes>
        <!--View Controller-->
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <rect key="frame" x="0.0" y="0.0" width="375" height="667"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <color key="backgroundColor" xcode11CocoaTouchSystemColor="systemBackgroundColor" cocoaTouchSystemColor="whiteColor"/>
                        <viewLayoutGuide key="safeArea" id="6Tk-OE-BBY"/>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
</document>

```

7. Create `resources/Main.storyboard`, and replace the entire file with this code:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="13122.16" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES" initialViewController="BYZ-38-t0r">
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="13104.12"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <scenes>
        <!--View Controller-->
        <scene sceneID="tne-QT-ifu">
            <objects>
                <viewController id="BYZ-38-t0r" customClass="ViewController" customModuleProvider="target" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToFill" id="8bC-Xf-vdC">
                        <rect key="frame" x="0.0" y="0.0" width="375" height="667"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <color key="backgroundColor" xcode11CocoaTouchSystemColor="systemBackgroundColor" cocoaTouchSystemColor="whiteColor"/>
                        <viewLayoutGuide key="safeArea" id="6Tk-OE-BBY"/>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="dkx-z0-nzr" sceneMemberID="firstResponder"/>
            </objects>
        </scene>
    </scenes>
</document>
```

8. Add the storyboard configuration to the Rakefile:

```ruby
  app.info_plist['UILaunchStoryboardName'] = 'LaunchScreen'
  app.info_plist['UIMainStoryboardFile'] = 'Main'
  app.info_plist['UIApplicationSceneManifest'] = {
   'UIApplicationSupportsMultipleScenes' => false,
    'UISceneConfigurations' => {
      'UIWindowSceneSessionRoleApplication' => [
        {
          'UISceneConfigurationName' => 'Default Configuration',
          'UISceneDelegateClassName' => 'SceneDelegate',
          'UISceneStoryboardFile' => 'Main'
        }
      ]
    }
  }
```

9. Hit `bundle exec rake simulator`, and you have a basic working app. You can now tap links and navigate the demo back and forth in the simulator. We've only touched the very core requirements here of creating a `Session` and handling a visit.

10. You can change the url we use for the initial visit to your web app. Note: if you're running your app locally without https, you'll need to adjust your `NSAppTransportSecurity` settings in the Info.plist to allow arbitrary loads.

11. A real application will want to customize the view controller, respond to different visit actions, gracefully handle errors, and build a more powerful routing system. Read the rest of the documentation to learn more.

