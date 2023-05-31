module Turbo
  class Session
    module VisitDelegateMethods
      def visitRequestDidStart(visit)
        delegate.sessionDidStartRequest(self) if delegate
      end

      def visitRequestDidFinish(visit)
        delegate.sessionDidFinishRequest(self) if delegate
      end

      def visit(visit, requestDidFailWithError: error)
        delegate.session(self, didFailRequestForVisitable: visit.visitable, withError: error) if delegate
      end

      def visitDidInitializeWebView(visit)
        @initialized = true
        delegate.sessionDidLoadWebView(self) if delegate
      end

      def visitWillStart(visit)
        visit.visitable.showVisitableScreenshot
        activateVisitable(visit.visitable)
      end

      def visitDidStart(visit)
        unless visit.hasCachedSnapshot
          visit.visitable.showVisitableActivityIndicator
        end
      end

      def visitWillLoadResponse(visit)
        visit.visitable.updateVisitableScreenshot
        visit.visitable.showVisitableScreenshot
      end

      def visitDidRender(visit)
        visit.visitable.hideVisitableScreenshot
        visit.visitable.hideVisitableActivityIndicator
        visit.visitable.visitableDidRender
      end

      def visitDidComplete(visit)
        if restorationIdentifier = visit.restorationIdentifier
          storeRestorationIdentifier(restorationIdentifier, forVisitable: visit.visitable)
        end
      end

      def visitDidFail(visit)
        visit.visitable.clearVisitableScreenshot
        visit.visitable.showVisitableScreenshot
        visit.visitable.hideVisitableActivityIndicator
      end

      def visitDidFinish(visit)
        if refreshing
          @refreshing = false
          visit.visitable.visitableDidRefresh
        end
      end

      def visit(visit, didReceiveAuthenticationChallenge: challenge, &completionHandler)
        delegate?.session(self, didReceiveAuthenticationChallenge: challenge, completionHandler: completionHandler)
      end
    end
  end
end
