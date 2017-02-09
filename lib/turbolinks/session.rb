module Turbolinks
  class Session
    include VisitDelegateMethods
    include VisitableDelegateMethods
    include WebViewDelegateMethods

    attr_accessor :delegate, :webView
    attr_reader :initialized,
                :refreshing,
                :activatedVisitable,
                :currentVisit,
                :topmostVisit,
                :topmostVisitable

    def initialize(options = {})
      webViewConfiguration = options[:webViewConfiguration] || WKWebViewConfiguration.alloc.init
      @webView = WebView.alloc.initWithConfiguration(webViewConfiguration)
      webView.delegate = self
      @initialized = false
      @refreshing = false
    end

    def visit(visitable)
      puts "Session#visit #{visitable.visitableURL.absoluteString}"
      visitVisitable(visitable, action: :advance)
    end

    def reload
      puts "Session#reload"
      if visitable = topmostVisitable
        @initialized = false
        visit(visitable)
        @topmostVisit = currentVisit
      end
    end

    private

    def visitVisitable(visitable, options)
      return unless visitable.visitableURL

      action = options[:action]
      visitable.visitableDelegate = self

      if initialized
        visit = JavaScriptVisit.new(visitable: visitable, action: action, webView: webView)
        visit.restorationIdentifier = restorationIdentifierForVisitable(visitable)
      else
        visit = ColdBootVisit.new(visitable: visitable, action: action, webView: webView)
      end

      @currentVisit.cancel if @currentVisit
      @currentVisit = visit

      visit.delegate = self
      visit.start
    end

    # Visitable restoration identifiers

    def visitableRestorationIdentifiers
      @visitableRestorationIdentifiers ||= NSMapTable.weakToStrongObjectsMapTable
    end

    def restorationIdentifierForVisitable(visitable)
      puts "Session#restorationIdentifierForVisitable"
      visitableRestorationIdentifiers.objectForKey(visitable)
    end

    def storeRestorationIdentifier(restorationIdentifier, forVisitable: visitable)
      puts "Session#completeNavigationForCurrentVisit"
      visitableRestorationIdentifiers.setObject(restorationIdentifier, forKey: visitable)
    end

    def completeNavigationForCurrentVisit
      puts "Session#completeNavigationForCurrentVisit"
      if currentVisit
        @topmostVisit = currentVisit
        currentVisit.completeNavigation
      end
    end

    # Visitable activation

    def activateVisitable(visitable)
      puts "Session#activateVisitable"
      return if visitable == activatedVisitable

      if activatedVisitable
        deactivateVisitable(activatedVisitable, showScreenshot: true)
      end

      visitable.activateVisitableWebView(webView)
      @activatedVisitable = visitable
    end

    private

    def deactivateVisitable(visitable, showScreenshot: showScreenshot)
      puts "Session#deactivateVisitable"
      if visitable == activatedVisitable
        if showScreenshot
          visitable.updateVisitableScreenshot
          visitable.showVisitableScreenshot
        end

        visitable.deactivateVisitableWebView
        @activatedVisitable = nil
      end
    end

  end
end
