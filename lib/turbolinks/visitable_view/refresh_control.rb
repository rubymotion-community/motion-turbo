module Turbolinks
  class VisitableView < UIView
    module RefreshControl
      def refreshControl
        @refreshControl ||= begin
          refreshControl = UIRefreshControl.alloc.init
          puts "VisitableView::RefreshControl#refreshControl"
          # TODO: refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
          refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEventValueChanged)
          refreshControl
        end
      end

      attr_reader :allowsPullToRefresh

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
        puts "VisitableView::RefreshControl#refresh"
        visitable.visitableViewDidRequestRefresh if visitable
      end

      private

      def installRefreshControl
        puts "VisitableView::RefreshControl#installRefreshControl"
        return unless webView && webView.scrollView && allowsPullToRefresh
        scrollView = webView?.scrollView
        webView.scrollView.addSubview(refreshControl)
      end

      def removeRefreshControl
        puts "VisitableView::RefreshControl#removeRefreshControl"
        refreshControl.endRefreshing
        refreshControl.removeFromSuperview
      end
    end
  end
end
