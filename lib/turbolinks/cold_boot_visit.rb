module Turbolinks
  class ColdBootVisit < Visit
    attr_reader :navigation

    def startVisit
      puts "ColdBootVisit#startVisit"
      webView.navigationDelegate = self
      webView.pageLoadDelegate = self

      request = NSURLRequest.alloc.initWithURL(location)
      @navigation = webView.loadRequest(request)

      delegate.visitDidStart(self) if delegate
      startRequest
    end

    def cancelVisit
      puts "ColdBootVisit#cancelVisit"
      removeNavigationDelegate
      webView.stopLoading
      finishRequest
    end

    def completeVisit
      puts "ColdBootVisit#completeVisit"
      removeNavigationDelegate
      delegate.visitDidInitializeWebView(self) if delegate
    end

    def failVisit
      puts "ColdBootVisit#failVisit"
      removeNavigationDelegate
      finishRequest
    end

    def removeNavigationDelegate
      puts "ColdBootVisit#removeNavigationDelegate"
      if webView.navigationDelegate == self
        webView.navigationDelegate = nil
      end
    end

    # WKNavigationDelegate methods

    def webView(webView, didFinishNavigation: navigation)
      puts "ColdBootVisit#webView:didFinishNavigation"
      if navigation == self.navigation
        finishRequest
      end
    end

    def webView(webView, decidePolicyForNavigationAction: navigationAction, decisionHandler: decisionHandler)
      puts "ColdBootVisit#webView:decidePolicyForNavigationAction:decisionHandler"
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
      puts "ColdBootVisit#webView:decidePolicyForNavigationResponse:decisionHandler"
      if httpResponse = navigationResponse.response
        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
          decisionHandler.call(WKNavigationResponsePolicyAllow)
        else
          decisionHandler.call(WKNavigationResponsePolicyCancel)
          fail do
            puts "ColdBootVisit#webView:decidePolicyForNavigationResponse:decisionHandler fail callback "
            error = Error.errorWithCode(:http_failure, statusCode: httpResponse.statusCode)
            self.delegate.visit(self, requestDidFailWithError: error) if delegate
          end
        end
      else
        decisionHandler.call(WKNavigationResponsePolicyCancel)
        fail do
          puts "ColdBootVisit#webView:decidePolicyForNavigationResponse:decisionHandler fail callback "
          error = Error.errorWithCode(:network_failure, localizedDescription: "An unknown error occurred")
          self.delegate.visit(self, requestDidFailWithError: error) if delegate
        end
      end
    end

    def webView(webView, didFailProvisionalNavigation: navigation, withError: originalError)
      puts "ColdBootVisit#webView:didFailProvisionalNavigation:withError"
      if navigation == self.navigation
        fail do
          puts "ColdBootVisit#webView:didFailProvisionalNavigation:withError fail callback "
          error = Error.errorWithCode(:network_failure, error: originalError)
          self.delegate.visit(self, requestDidFailWithError: error) if delegate
        end
      end
    end

    def webView(webView, didFailNavigation: navigation, withError: originalError)
      puts "ColdBootVisit#webView:didFailNavigation:withError"
      if navigation === self.navigation
        fail do
          error = Error.errorWithCode(:network_failure, error: originalError)
          self.delegate.visit(self, requestDidFailWithError: error) if delegate
        end
      end
    end

    # WebViewPageLoadDelegate

    def webView(webView, didLoadPageWithRestorationIdentifier: restorationIdentifier)
      puts "ColdBootVisit#webView:didLoadPageWithRestorationIdentifier"
      @restorationIdentifier = restorationIdentifier
      delegate.visitDidRender(self) if delegate
      complete
    end

  end
end
