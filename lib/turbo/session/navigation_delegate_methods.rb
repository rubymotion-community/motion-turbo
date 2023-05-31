module Turbo
  class Session
    module NavigationDelegateMethods

      attr_accessor :navigationAction

      def webView(webview, decidePolicyForNavigationAction: navigationAction, decisionHandler: decisionHandler)
        navigationDecision = NavigationDecision(navigationAction: navigationAction)
        decisionHandler(navigationDecision.policy)

        if url = navigationDecision.externallyOpenableURL
          openExternalURL(url)
        elsif navigationDecision.shouldReloadPage
          reload
        end
      end

      def policy
        navigationAction.navigationType == WKNavigationTypeLinkActivated || isMainFrameNavigation ? WKNavigationResponsePolicyCancel : WKNavigationResponsePolicyAllow
      end

      def externallyOpenableURL
        if url = navigationAction.request.url && shouldOpenURLExternally
          url
        end
      end

      def shouldOpenURLExternally
        type = navigationAction.navigationType
        return type == WKNavigationTypeLinkActivated || (isMainFrameNavigation && type == WKNavigationTypeOther)
      end

      def shouldReloadPage
        type = navigationAction.navigationType
        return isMainFrameNavigation && type == WKNavigationTypeReload
      end

      def isMainFrameNavigation
        navigationAction.targetFrame.isMainFrame if navigationAction.targetFrame
      end
    end
  end
end
