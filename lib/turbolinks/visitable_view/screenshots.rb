module Turbolinks
  class VisitableView < UIView
    module Screenshots
      def screenshotContainerView
        @screenshotContainerView ||= begin
          puts "VisitableView::Screenshots#screenshotContainerView"
          view = UIView.alloc.initWithFrame(CGRectZero)
          view.translatesAutoresizingMaskIntoConstraints = false
          view.backgroundColor = backgroundColor
          view
        end
      end

      attr_reader :screenshotView

      def isShowingScreenshot
        puts "VisitableView::Screenshots#isShowingScreenshot"
        screenshotContainerView.superview != nil
      end

      def updateScreenshot
        puts "VisitableView::Screenshots#updateScreenshot"
        return unless webView
        return if isShowingScreenshot
        screenshot = webView.snapshotViewAfterScreenUpdates(false)
        return unless screenshot

        screenshotView.removeFromSuperview if screenshotView
        screenshot.translatesAutoresizingMaskIntoConstraints = false
        screenshotContainerView.addSubview(screenshot)
        screenshotContainerView.addConstraints([
          NSLayoutConstraint.constraintWithItem(screenshot, attribute: NSLayoutAttributeCenterX, relatedBy: NSLayoutRelationEqual, toItem: screenshotContainerView, attribute: NSLayoutAttributeCenterX, multiplier: 1, constant: 0),
          NSLayoutConstraint.constraintWithItem(screenshot, attribute: NSLayoutAttributeTop,     relatedBy: NSLayoutRelationEqual, toItem: screenshotContainerView, attribute: NSLayoutAttributeTop, multiplier: 1, constant: 0),
          NSLayoutConstraint.constraintWithItem(screenshot, attribute: NSLayoutAttributeWidth,   relatedBy: NSLayoutRelationEqual, toItem: nil, attribute: NSLayoutAttributeNotAnAttribute, multiplier: 1, constant: screenshot.bounds.size.width),
          NSLayoutConstraint.constraintWithItem(screenshot, attribute: NSLayoutAttributeHeight,  relatedBy: NSLayoutRelationEqual, toItem: nil, attribute: NSLayoutAttributeNotAnAttribute, multiplier: 1, constant: screenshot.bounds.size.height)
        ])
        @screenshotView = screenshot
      end

      def showScreenshot
        puts "VisitableView::Screenshots#showScreenshot"
        if !isShowingScreenshot && !isRefreshing
          addSubview(screenshotContainerView)
          addFillConstraintsForSubview(screenshotContainerView)
          showOrHideWebView
        end
      end

      def hideScreenshot
        puts "VisitableView::Screenshots#hideScreenshot"
        screenshotContainerView.removeFromSuperview
        showOrHideWebView
      end

      def clearScreenshot
        puts "VisitableView::Screenshots#clearScreenshot"
        screenshotView.removeFromSuperview if screenshotView
      end
    end
  end
end
