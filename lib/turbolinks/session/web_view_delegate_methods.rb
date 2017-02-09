module Turbolinks
  class Session
    module WebViewDelegateMethods
      def webView(webView, didProposeVisitToLocation: location, withAction: action)
        puts "Session::WebViewDelegateMethods#webView:didProposeVisitToLocation:withAction"
        delegate.session(self, didProposeVisitToURL: location, withAction: action) if delegate
      end

      def webViewDidInvalidatePage(webView)
        puts "Session::WebViewDelegateMethods#webViewDidInvalidatePage"
        if topmostVisitable
          topmostVisitable.updateVisitableScreenshot
          topmostVisitable.showVisitableScreenshot
          topmostVisitable.showVisitableActivityIndicator
          reload
        end
      end

      def webView(webView, didFailJavaScriptEvaluationWithError: error)
        puts "Session::WebViewDelegateMethods#webView:didFailJavaScriptEvaluationWithError"
        if currentVisit && initialized
          @initialized = false
          currentVisit.cancel
          visit(currentVisit.visitable)
        end
      end
    end
  end
end
