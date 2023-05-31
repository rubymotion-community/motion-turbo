module Turbo
  class VisitableView < UIView
    module ScrollView
      private

      def hiddenScrollView
        @hiddenScrollView ||= begin
          scrollView = UIScrollView.alloc.initWithFrame(CGRectZero)
          scrollView.translatesAutoresizingMaskIntoConstraints = false
          scrollView.scrollsToTop = false
          scrollView
        end
      end

      def installHiddenScrollView
        insertSubview(hiddenScrollView, atIndex: 0)
        addFillConstraintsForSubview(hiddenScrollView)
      end
    end
  end
end
