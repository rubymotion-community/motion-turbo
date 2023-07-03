module Turbo
  class Session
    module VisitableDelegateMethods
      def visitableViewWillAppear(visitable)
        return unless topmostVisit && currentVisit

        if visitable == topmostVisit.visitable && visitable.visitableViewController.isMovingToParentViewController
          # Back swipe gesture canceled
          if topmostVisit.state.to_sym == :completed
            currentVisit.cancel
          else
            visitVisitable(visitable, action: :advance)
          end
        elsif visitable == currentVisit.visitable && currentVisit.state.to_sym == :started
          # Navigating forward - complete navigation early
          completeNavigationForCurrentVisit
        elsif visitable != topmostVisit.visitable
          # Navigating backward
          visitVisitable(visitable, action: :restore)
        end
      end

      def visitableViewDidAppear(visitable)
        if currentVisit && visitable == currentVisit.visitable
          # Appearing after successful navigation
          completeNavigationForCurrentVisit
          if currentVisit.state.to_sym != :failed
            activateVisitable(visitable)
          end
        elsif topmostVisit && visitable == topmostVisit.visitable && topmostVisit.state == :completed
          # Reappearing after canceled navigation
          visitVisitable(visitable, action: :restore)
        end
      end

      def visitableDidRequestReload(visitable)
        if visitable == topmostVisitable
          reload
        end
      end

      def visitableDidRequestRefresh(visitable)
        if visitable == topmostVisitable
          @refreshing = true
          visitable.visitableWillRefresh
          reload
        end
      end
    end
  end
end
