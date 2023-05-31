module Turbo
  # A Session represents the main interface for managing
  # a Turbo app in a web view. Each Session manages a single web view
  # so you should create multiple sessions to have multiple web views, for example
  # when using modals or tabs
  class Session
    include VisitDelegateMethods
    include VisitableDelegateMethods
    include WebViewDelegateMethods
    include SessionDelegateMethods
    include NavigationDelegateMethods

    attr_accessor :delegate, :webView, :pathConfiguration, :bridge
    attr_reader :initialized,
                :refreshing,
                :activatedVisitable,
                :currentVisit,
                :topmostVisit,
                :topmostVisitable

    def init
      initWithConfiguration(WKWebViewConfiguration.alloc.init)
    end

    def initWithConfiguration(configuration)
      webViewConfiguration = configuration
      #webView = WKWebView.alloc.initWithFrame(CGRectZero, configuration: webViewConfiguration)
      webView = WKWebView.alloc.initWithFrame(CGRectMake(-50,050,450,100), configuration: webViewConfiguration)
      webView.layer.borderColor = UIColor.blueColor
      webView.layer.borderWidth = 2

      initWithWebView(webView)
    end

    def initWithWebView(webView)
      @webView = webView
      @initialized = false
      @refreshing = false
      setup
      self
    end

    private

    def bridge
      @bridge ||= WebViewBridge.alloc.initWithWebView(webView)
    end

    def setup
      webView.translatesAutoresizingMaskIntoConstraints = false
      bridge.delegate = self
    end

    public

    # The topmost visitable is the visitable that has most recently completed a visit
    def topmostVisitable
      topmostVisit.visitable if topmostVisit
    end

    # The active visitable is the visitable that currently owns the web view
    def activeVisitable
      activatedVisitable
    end

    def visitVisitable(visitable)
      visitVisitable(visitable, options: nil)
    end

    def visitVisitable(visitable, action: action)
      visitVisitable(visitable, options: VisitOptions.alloc.initWithAction(action, response: nil))
    end

    def visitVisitable(visitable, options: options)
      visitVisitable(visitable, options: options, reload: false)
    end

    def visitVisitable(visitable, options: options, reload: reload)
      # TODO raise instead?
      raise "Visitable must provide a url! #{visitable}" unless visitable.visitableURL

      visitable.visitableDelegate = self

      if reload
        @initialized = false
      end

      visit = makeVisit(visitable, options: options || VisitOptions.alloc.initFromHash({}))
      @currentVisit.cancel if currentVisit
      @currentVisit = visit

      log("visit", { location: visit.location, options: visit.options, reload: reload })

      visit.delegate = self
      visit.start
    end

    def makeVisit(visitable, options: options)
      if initialized
        restorationIdentifier = restorationIdentifierForVisitable(visitable)
        JavaScriptVisit.alloc.initWithVisitable(visitable, options: options, bridge: bridge, restorationIdentifier: restorationIdentifier)
      else
        ColdBootVisit.alloc.initWithVisitable(visitable, options: options, bridge: bridge)
      end
    end

    def reload
      return unless visitable = topmostVisitable
      @initialized = false
      visitVisitable(visitable)
      @topmostVisit = currentVisit
    end

    def clearSnapshotCache
      bridge.clearSnapshotCache
    end

    # Visitable activation

    private

    def activateVisitable(visitable)
      return if isActivatedVisitable(visitable)

      deactivateActivatedVisitable
      visitable.activateVisitableWebView(webView)
      @activatedVisitable = visitable
    end

    def deactivateActivatedVisitable
      if activatedVisitable
        deactivateVisitable(activatedVisitable, showScreenshot: true)
      end
    end

    def deactivateVisitable(visitable, showScreenshot: showScreenshot)
      if visitable == activatedVisitable
        if showScreenshot
          visitable.updateVisitableScreenshot
          visitable.showVisitableScreenshot
        end

        visitable.deactivateVisitableWebView
        @activatedVisitable = nil
      end
    end

    def isActivatedVisitable(visitable)
      visitable == activatedVisitable
    end

    # Visitable restoration identifiers

    def visitableRestorationIdentifiers
      @visitableRestorationIdentifiers ||= NSMapTable.weakToStrongObjectsMapTable
    end

    def restorationIdentifierForVisitable(visitable)
      visitableRestorationIdentifiers.objectForKey(visitable.visitableViewController)
    end

    def storeRestorationIdentifier(restorationIdentifier, forVisitable: visitable)
      visitableRestorationIdentifiers.setObject(restorationIdentifier, forKey: visitable.visitableViewController)
    end

    # MARK: - Navigation

    def completeNavigationForCurrentVisit
      if currentVisit
        @topmostVisit = currentVisit
      end
    end

    private

    def log(name)
      log(name, {})
    end

    def log(name, arguments)
      debugLog("[Session] #{name}", arguments: arguments)
    end
  end
end
