module Turbo
  class Session
    module WebViewDelegateMethods
      def webView(webView, didProposeVisitToLocation: location, withOptions: options)
        properties = pathConfiguration ? pathConfiguration.propertiesForURL(location) : {}
        proposal = VisitProposal.alloc.initWithURL(location, options: options, properties: properties)
        delegate.session(self, didProposeVisitProsal: proposal) if delegate
      end

      def webView(webView, didStartFormSubmissionToLocation: location)
        delegate.sessionDidStartFormSubmission(self) if delegate
      end

      def webView(webView, didFinishFormSubmissionToLocation: location)
        delegate.sessionDidFinishFormSubmission(self) if delegate
      end

      def webViewDidInvalidatePage(webView)
        if topmostVisitable
          topmostVisitable.updateVisitableScreenshot
          topmostVisitable.showVisitableScreenshot
          topmostVisitable.showVisitableActivityIndicator
          reload
        end
      end

      # Initial page load failed, this will happen when we couldn't find Turbo JS on the page
      def webView(webView, didFailInitialPageLoadWithError: error)
        return unless currentVisit = self.currentVisit && !initialized

        @initialized = false
        currentVisit.cancel
        visitDidFail(currentVisit)
        visit(currentVisit, requestDidFailWithError: error)
      end

      def webView(webView, didFailJavaScriptEvaluationWithError: error)
        return unless currentVisit = self.currentVisit && initialized

        @initialized = false
        currentVisit.cancel
        visit(currentVisit.visitable)
      end
    end
  end
end
