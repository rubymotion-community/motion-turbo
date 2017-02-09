module Turbolinks
  class VisitableView < UIView
    module WebView
      attr_reader :webView, :visitable

      def activateWebView(webView, forVisitable: visitable)
        puts "VisitableView::WebView#activateWebView:forVisitable"
        @webView = webView
        @visitable = visitable
        addSubview(webView)
        addFillConstraintsForSubview(webView)
        updateContentInsets
        installRefreshControl
        showOrHideWebView
      end

      def deactivateWebView
        puts "VisitableView::WebView#deactivateWebView"
        removeRefreshControl
        webView.removeFromSuperview if webView
        @webView = nil
        @visitable = nil
      end

      def showOrHideWebView
        puts "VisitableView::WebView#showOrHideWebView"
        webView.hidden = isShowingScreenshot if webView
      end
    end
  end
end
