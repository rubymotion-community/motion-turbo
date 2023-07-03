module Turbo
  # A "Cold Boot" visit is the initial visit to load the page, including all resources
  # Subsequent visits go through Turbo and use `JavaScriptVisit`
  class ColdBootVisit < Visit
    attr_reader :navigation

    def startVisit
      log("startVisit")
      webView.navigationDelegate = self
      bridge.pageLoadDelegate = self

      request = NSURLRequest.alloc.initWithURL(location)
      @navigation = webView.loadRequest(request)

      delegate.visitDidStart(self) if delegate
      startRequest
    end

    def cancelVisit
      log("cancelVisit")
      removeNavigationDelegate
      webView.stopLoading
      finishRequest
    end

    def completeVisit
      log("completeVisit")
      removeNavigationDelegate
      delegate.visitDidInitializeWebView(self) if delegate
    end

    def failVisit
      log("cancelVisit")
      removeNavigationDelegate
      finishRequest
    end

    def removeNavigationDelegate
      if webView.navigationDelegate == self
        webView.navigationDelegate = nil
      end
    end

    private

    def log(name)
      debugLog("[ColdBootVisit] #{name} #{location.absoluteString}")
    end

    # WKNavigationDelegate methods

    public

    def webView(webView, didFinishNavigation: navigation)
      if navigation == self.navigation
        finishRequest
      end
    end

    def webView(webView, decidePolicyForNavigationAction: navigationAction, decisionHandler: decisionHandler)
      @navigationActionDecisionHandler = decisionHandler
      # Ignore any clicked links before the cold boot finishes navigation
      if navigationAction.navigationType == WKNavigationTypeLinkActivated
        @navigationActionDecisionHandler.call(WKNavigationActionPolicyCancel)
        if url = navigationAction.request.URL
          UIApplication.sharedApplication.openURL(url)
        end
      else
        @navigationActionDecisionHandler.call(WKNavigationActionPolicyAllow)
      end
    end

    def webView(webView, decidePolicyForNavigationResponse: navigationResponse, decisionHandler: decisionHandler)
      if httpResponse = navigationResponse.response
        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
          decisionHandler.call(WKNavigationResponsePolicyAllow)
        else
          decisionHandler.call(WKNavigationResponsePolicyCancel)
          fail(TurboError.errorWithCode(:http_failure, statusCode: httpResponse.statusCode))
        end
      else
        decisionHandler.call(WKNavigationResponsePolicyCancel)
        fail(TurboError.errorWithCode(:network_failure, localizedDescription: "An unknown error occurred"))
      end
    end

    def webView(webView, didFailProvisionalNavigation: navigation, withError: originalError)
      if navigation == self.navigation
        fail(TurboError.errorWithCode(:network_failure, error: originalError))
      end
    end

    def webView(webView, didFailNavigation: navigation, withError: originalError)
      if navigation === self.navigation
        fail(TurboError.errorWithCode(:network_failure, error: originalError))
      end
    end

    # WebViewPageLoadDelegate

    def webView(webView, didLoadPageWithRestorationIdentifier: restorationIdentifier)
      @restorationIdentifier = restorationIdentifier
      delegate.visitDidRender(self) if delegate
      complete
    end

  end
end

