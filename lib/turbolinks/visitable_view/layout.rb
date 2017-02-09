module Turbolinks
  class VisitableView < UIView
    module Layout
      attr_reader :contentInset

      def contentInset=(contentInset)
        @contentInset = contentInset
        updateContentInsets
      end

      def layoutSubviews
        puts "VisitableView::Layout#layoutSubviews"
        super
        updateContentInsets
      end

      private

      def needsUpdateForContentInsets(adjustedInsets)
        puts "VisitableView::Layout#needsUpdateForContentInsets"
        return false unless webView && webView.scrollView
        scrollView = webView.scrollView
        return (scrollView.contentInset.top != adjustedInsets.top && adjustedInsets.top != 0) ||
               (scrollView.contentInset.bottom != adjustedInsets.bottom && adjustedInsets.bottom != 0)
      end

      def updateWebViewScrollViewInsets(adjustedInsets)
        puts "VisitableView::Layout#updateWebViewScrollViewInsets"
        return unless webView && webView.scrollView
        scrollView = webView.scrollView
        if needsUpdateForContentInsets(adjustedInsets) && !isRefreshing
          scrollView.scrollIndicatorInsets = adjustedInsets
          scrollView.contentInset = adjustedInsets
        end
      end

      def updateContentInsets
        puts "VisitableView::Layout#updateContentInsets"
        updateWebViewScrollViewInsets(contentInset || hiddenScrollView.contentInset)
      end

      def addFillConstraintsForSubview(view)
        puts "VisitableView::Layout#addFillConstraintsForSubview"
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: 0, metrics: nil, views: { "view" => view }))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: 0, metrics: nil, views: { "view" => view }))
      end
    end
  end
end
