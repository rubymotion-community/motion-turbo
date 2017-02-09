module Turbolinks
  class VisitableView < UIView
    module ActivityIndicator
      def activityIndicatorView
        @activityIndicatorView ||= begin
          view = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhite)
          view.translatesAutoresizingMaskIntoConstraints = false
          view.color = UIColor.grayColor
          view.hidesWhenStopped = true
          view
        end
      end

      def showActivityIndicator
        if !isRefreshing
          activityIndicatorView.startAnimating
          bringSubviewToFront(activityIndicatorView)
        end
      end

      def hideActivityIndicator
        activityIndicatorView.stopAnimating
      end

      private

      def installActivityIndicatorView
        addSubview(activityIndicatorView)
        addFillConstraintsForSubview(activityIndicatorView)
      end
    end
  end
end
