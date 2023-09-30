class SceneController < UIResponder
  include Turbo::Session::SessionDelegateMethods

  attr_accessor :window, :navigationController

  def rootURL
    @rootURL ||= NSURL.alloc.initWithString("https://turbo-native-demo.glitch.me")
  end

  def configureRootViewController
    #TODO
    # guard let window = window else {
    #   fatalError()
    # }

    window.tintColor = UIColor.colorNamed("Tint")

    if navController = castRootControllerToTurboNavigationController
      turboNavController = navController
      self.navigationController = navController
    else
      turboNavController = TurboNavigationController.alloc.init
      window.rootViewController = turboNavController
    end

    turboNavController.session = session
    turboNavController.modalSession = modalSession
  end

  # TODO make private
  def castRootControllerToTurboNavigationController
    navigationController = window.rootViewController
    if navigationController.is_a?(TurboNavigationController)
      navigationController
    elsif navigationController.is_a?(UINavigationController)
      window.rootViewController = TurboNavigationController.alloc.init
    else
      false
    end
  end

  # MARK: - Authentication

  def promptForAuthentication
    authURL = rootURL.URLByAppendingPathComponent("/signin")
    properties = pathConfiguration.propertiesForURL(authURL)
    navigationController.route(authURL, options: Turbo::VisitOptions.alloc.initFromHash({}), properties: properties)
  end

  def session
    @session ||= makeSession
  end

  def modalSession
    @modalSession ||= makeSession
  end

  def makeSession
    configuration = WKWebViewConfiguration.alloc.init
    configuration.applicationNameForUserAgent = "Turbo Native iOS"
    configuration.processPool = self.class.sharedProcessPool
    #webView = WKWebView.alloc.initWithFrame(CGRectZero, configuration: configuration)
    webView = WKWebView.alloc.initWithFrame(CGRectMake(50,50,50,50), configuration: configuration)

    #if #available(iOS 16.4, *) {
      #webView.isInspectable = true
    #}
    session = Turbo::Session.alloc.initWithWebView(webView)
    session.delegate = self
    session.pathConfiguration = pathConfiguration
    session
  end

  def self.sharedProcessPool
    @sharedProcessPool ||= WKProcessPool.new
  end

  # MARK: - Path Configuration

  def pathConfiguration
    bundle = NSBundle.bundleForClass(self)
    source = bundle.URLForResource("path-configuration", withExtension: "json")
    @pathConfiguration ||= Turbo::PathConfiguration.alloc.initWithSources([source])
  end

  # UIWindowSceneDelegate

  def scene(scene, willConnectToSession: session, options: options)
    # TODO guard let _ = scene as? UIWindowScene else { return }

    configureRootViewController
    navigationController.route(rootURL, options: Turbo::VisitOptions.alloc.initFromHash({ action: :replace }), properties: {})
  end

  # SessionDelegate

  def session(session, didProposeVisit: proposal)
    navigationController.route(proposal.url, options: proposal.options, properties: proposal.properties)
  end

  def session(session, didFailRequestForVisitable: visitable, withError: error)
    if error.is_a?(Turbo::TurboError) && error.statusCode == 401
      #case let .http(statusCode) = turboError, statusCode == 401 {
      promptForAuthentication
    elsif visitable.is_a?(ErrorPresenter)
      visitable.presentError(error) do
        self.session.reload if self
      end
    else
      alert = UIAlertController.alertControllerWithTitle("Visit failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyleAlert)
      alert.addAction(UIAlertAction.actionWithTitle("OK", style: UIAlertActionStyleDefault, handler: nil))
      @navigationController.presentViewController(alert, animated: true, completion: nil)
    end
  end

  # When a form submission completes in the modal session, we need to
  # manually clear the snapshot cache in the default session, since we
  # don't want potentially stale cached snapshots to be used
  def sessionDidFinishFormSubmission(session)
    if (session == @modalSession)
      session.clearSnapshotCache
    end
  end

  def sessionDidLoadWebView(session)
    session.webView.navigationDelegate = self
  end

  def sessionWebViewProcessDidTerminate(session)
    session.reload
  end

  # WKNavigationDelegate

  def webView(webView, decidePolicyForNavigationAction: navigationAction, decisionHandler: decisionHandler)
    @navigationActionDecisionHandler = decisionHandler
    if navigationAction.navigationType == WKNavigationTypeLinkActivated
      # Any link that's not on the same domain as the Turbo root url will go through here
      # Other links on the domain, but that have an extension that is non-html will also go here
      # You can decide how to handle those, by default if you're not the navigationDelegate
      # the Session will open them in the default browser
      url = navigationAction.request.URL

      # For this demo, we'll load files from our domain in a SafariViewController so you
      # don't need to leave the app. You might expand this in your app
      # to open all audio/video/images in a native media viewer
      if url.host == rootURL.host && !url.pathExtension.empty?
        safariViewController = SFSafariViewController.alloc.initWithURL(url)
        navigationController.presentModalViewController(safariViewController, animated: true)
      else
        UIApplication.sharedApplication.openURL(url)
      end
      @navigationActionDecisionHandler.call(WKNavigationActionPolicyCancel)
    else
      @navigationActionDecisionHandler.call(WKNavigationActionPolicyAllow)
    end
  end
end
