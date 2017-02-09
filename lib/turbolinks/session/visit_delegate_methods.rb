module Turbolinks
  class Session
    module VisitDelegateMethods
      def visitDidInitializeWebView(visit)
        puts "Session::VisitDelegateMethods#visitDidInitializeWebView"
        @initialized = true
        delegate.sessionDidLoadWebView(self) if delegate && delegate.respond_to?(:sessionDidLoadWebView)
      end

      def visitWillStart(visit)
        puts "Session::VisitDelegateMethods#visitWillStart"
        visit.visitable.showVisitableScreenshot
        activateVisitable(visit.visitable)
      end

      def visitDidStart(visit)
        puts "Session::VisitDelegateMethods#visitDidStart"
        unless visit.hasCachedSnapshot
          visit.visitable.showVisitableActivityIndicator
        end
      end

      def visitDidComplete(visit)
        puts "Session::VisitDelegateMethods#visitDidComplete"
        if restorationIdentifier = visit.restorationIdentifier
          storeRestorationIdentifier(restorationIdentifier, forVisitable: visit.visitable)
        end
      end

      def visitDidFail(visit)
        puts "Session::VisitDelegateMethods#visitDidFail"
        visit.visitable.clearVisitableScreenshot
        visit.visitable.showVisitableScreenshot
      end

      def visitDidFinish(visit)
        puts "Session::VisitDelegateMethods#visitDidFinish"
        if refreshing
          @refreshing = false
          visit.visitable.visitableDidRefresh
        end
      end

      def visitWillLoadResponse(visit)
        puts "Session::VisitDelegateMethods#visitWillLoadResponse"
        visit.visitable.updateVisitableScreenshot
        visit.visitable.showVisitableScreenshot
      end

      def visitDidRender(visit)
        puts "Session::VisitDelegateMethods#visitDidRender"
        visit.visitable.hideVisitableScreenshot
        visit.visitable.hideVisitableActivityIndicator
        visit.visitable.visitableDidRender
      end

      def visitRequestDidStart(visit)
        puts "Session::VisitDelegateMethods#visitRequestDidStart"
        delegate.sessionDidStartRequest(self) if delegate # TODO? && delegate.respond_to?(:sessionDidStartRequest)
      end

      def visit(visit, requestDidFailWithError: error)
        puts "Session::VisitDelegateMethods#visit:requestDidFailWithError"
        delegate.session(self, didFailRequestForVisitable: visit.visitable, withError: error) if delegate # TODO? && delegate.respond_to? ...
      end

      def visitRequestDidFinish(visit)
        puts "Session::VisitDelegateMethods#visitRequestDidFinish"
        delegate.sessionDidFinishRequest(self) if delegate # TODO? && delegate.respond_to? ...
      end
    end
  end
end
