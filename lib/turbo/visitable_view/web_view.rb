module Turbo
  class VisitableView < UIView
    module WebView
      attr_reader :webView, :visitable

      def activateWebView(webView, forVisitable: visitable)
        @webView = webView
        @visitable = visitable
        #addSubview(webView)
        insertSubview(webView, atIndex: 0)
        addFillConstraintsForSubview(webView)
        installRefreshControl
        showOrHideWebView
      end

      def deactivateWebView
        removeRefreshControl
        webView.removeFromSuperview if webView
        @webView = nil
        @visitable = nil
      end

      def showOrHideWebView
        webView.hidden = isShowingScreenshot if webView
      end
    end
  end
end
