module Turbo
  class VisitableView < UIView
    module RefreshControl
      def refreshControl
        @refreshControl ||= begin
          refreshControl = UIRefreshControl.alloc.init
          refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEventValueChanged)
          refreshControl
        end
      end

      def allowsPullToRefresh
        return @allowsPullToRefresh if defined?(@allowsPullToRefresh)
        @allowsPullToRefresh = true
      end

      def allowsPullToRefresh=(allowsPullToRefresh)
        @allowsPullToRefresh = allowsPullToRefresh
        if allowsPullToRefresh
          installRefreshControl
        else
          removeRefreshControl
        end
      end

      def isRefreshing
        refreshControl.refreshing?
      end

      def refresh(sender)
        visitable.visitableViewDidRequestRefresh if visitable
      end

      private

      def installRefreshControl
        scrollView = webView.scrollView if webView
        return unless scrollView && allowsPullToRefresh
        # TODO
        #if !targetEnvironment(macCatalyst)
        scrollView.addSubview(refreshControl)

        # Infer refresh control's default height from its frame, if given.
        # Otherwise fallback to 60 (the default height).
        refreshControlHeight = CGRectGetHeight(refreshControl.frame) > 0 ? CGRectGetHeight(refreshControl.frame) : 60
        NSLayoutConstraint.activateConstraints([
            refreshControl.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
            refreshControl.topAnchor.constraintEqualToAnchor(safeAreaLayoutGuide.topAnchor),
            refreshControl.heightAnchor.constraintEqualToConstant(refreshControlHeight)
        ])
        #endif
      end

      def removeRefreshControl
        refreshControl.endRefreshing
        #refreshControl.removeFromSuperview
        webView.scrollView.refreshControl = nil
      end
    end
  end
end
