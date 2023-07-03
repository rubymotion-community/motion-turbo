module Turbo
  class VisitableView < UIView
    module ActivityIndicator
      def activityIndicatorView
        @activityIndicatorView ||= begin
          view = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleMedium)
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
        NSLayoutConstraint.activateConstraints([
          activityIndicatorView.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
          activityIndicatorView.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
        ])
      end
    end
  end
end
