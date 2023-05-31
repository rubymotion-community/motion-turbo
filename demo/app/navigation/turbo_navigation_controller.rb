class TurboNavigationController < UINavigationController
  attr_accessor :session, :modalSession

  def push(url)
    properties = session.pathConfiguration ? session.pathConfiguration.propertiesForURL(url) : {}
    route(url,
          options: Turbo::VisitOptions.alloc.initFromHash({action: :advance}),
          properties: properties)
  end

  def route(url, options: options, properties: properties)
    # This is a simplified version of how you might build out the routing
    # and navigation functions of your app. In a real app, these would be separate objects

    # Dismiss any modals when receiving a new navigation
    if presentedViewController != nil
      dismissModalViewControllerAnimated(true)
    end

    # Special case of navigating home, issue a reload
    if url.path == "/" && !viewControllers.empty?
      popViewControllerAnimated(false)
      session.reload
      return
    end

    # - Create view controller appropriate for url/properties
    # - Navigate to that with the correct presentation
    # - Initiate the visit with Turbo
    viewController = makeViewControllerForURL(url, properties: properties)
    navigate(viewController, action: options.action, properties: properties, animated: true)
    visit(viewController, options: options, modal: isModal(session, properties: properties))
  end

  private

  def isModal(session, properties: properties)
    # For simplicity, we're using string literals for various keys and values of the path configuration
    # but most likely you'll want to define your own enums these properties
    presentation = properties["presentation"]
    presentation == "modal"
  end

  def makeViewControllerForURL(url, properties: properties)
    # There are many options for determining how to map urls to view controllers
    # The demo uses the path configuration for determining which view controller and presentation
    # to use, but that's completely optional. You can use whatever logic you prefer to determine
    # how you navigate and route different URLs.

    if viewController = properties["view-controller"]
      case viewController
      when "numbers"
        numbersVC = NumbersViewController.new
        numbersVC.url = url
        return numbersVC
      when "numbersDetail"
        alertController = UIAlertController.alertControllerWithTitle("Number", message: "#{url.lastPathComponent}", preferredStyle: UIAlertControllerStyleAlert)
        alertController.addAction(UIAlertAction.actionWithTitle("OK", style: UIAlertActionStyleDefault, handler: nil))
        return alertController
      else
        assertionFailure("Invalid view controller, defaulting to WebView")
      end
    end

    ViewController.alloc.initWithURL(url)
  end

  def navigate(viewController, action: action, properties: properties, animated: animated)
    # We support three types of navigation in the app: advance, replace, and modal
    if isModal(session, properties: properties)
      if viewController.is_a? UIAlertController
        presentViewController(viewController, animated: animated, completion: nil)
      else
        modalNavController = UINavigationController.alloc.initWithRootViewController(viewController)
        presentModalViewController(modalNavController, animated: animated)
      end
    elsif action && action.to_sym == :replace
      #self.viewControllers.pop # = viewControllers.dropLast()) + [viewController]
      cs = self.viewControllers.dup
      cs.pop
      self.viewControllers = cs + [viewController]
      setViewControllers(viewControllers, animated: false)
    else
      pushViewController(viewController, animated: animated)
    end
  end

  def visit(viewController, options: options, modal: modal)
    #guard let visitable = viewController as? Visitable else { return }
    visitable = viewController
    return unless visitable.is_a?(Turbo::Visitable)
    raise unless options.is_a?(Turbo::VisitOptions)
    # Each Session corresponds to a single web view. A good rule of thumb
    # is to use a session per navigation stack. Here we're using a different session
    # when presenting a modal. We keep that around for any modal presentations so
    # we don't have to create more than we need since each new session incurs a cold boot visit cost
    if modal
      modalSession.visitVisitable(visitable, options: options)
    else
      session.visitVisitable(visitable, options: options)
    end
  end
end
