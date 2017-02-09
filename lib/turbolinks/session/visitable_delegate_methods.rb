module Turbolinks
  class Session
    module VisitableDelegateMethods
      def visitableViewWillAppear(visitable)
        puts "Session::VisitableDelegateMethods#visitableViewWillAppear"
        return unless topmostVisit && currentVisit

        if visitable == topmostVisit.visitable && visitable.visitableViewController.isMovingToParentViewController()
          # // Back swipe gesture canceled
          if topmostVisit.state == :completed
            currentVisit.cancel
          else
            visitVisitable(visitable, action: :advance)
          end
        elsif visitable == currentVisit.visitable && currentVisit.state == :started
          # // Navigating forward - complete navigation early
          completeNavigationForCurrentVisit
        elsif visitable != topmostVisit.visitable
          # // Navigating backward
          visitVisitable(visitable, action: :restore)
        end
      end

      def visitableViewDidAppear(visitable)
        puts "Session::VisitableDelegateMethods#visitableViewDidAppear"
        if currentVisit && visitable == currentVisit.visitable
          # // Appearing after successful navigation
          completeNavigationForCurrentVisit
          if currentVisit.state != :failed
            activateVisitable(visitable)
          end
        elsif topmostVisit && visitable == topmostVisit.visitable && topmostVisit.state == :completed
          # // Reappearing after canceled navigation
          visitable.hideVisitableScreenshot
          visitable.hideVisitableActivityIndicator
          activateVisitable(visitable)
        end
      end

      # TODO

      # def visitableDidRequestReload(visitable: Visitable) {
      #     if visitable === topmostVisitable {
      #         reload()
      #     end
      # end
      #
      # def visitableDidRequestRefresh(visitable: Visitable) {
      #     if visitable === topmostVisitable {
      #         refreshing = true
      #         visitable.visitableWillRefresh()
      #         reload()
      #     end
      # end
    end
  end
end
