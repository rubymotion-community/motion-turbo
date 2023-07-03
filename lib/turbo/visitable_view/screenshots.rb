module Turbo
  class VisitableView < UIView
    module Screenshots
      def screenshotContainerView
        @screenshotContainerView ||= begin
          view = UIView.alloc.initWithFrame(CGRectZero)
          view.translatesAutoresizingMaskIntoConstraints = false
          view.backgroundColor = backgroundColor
          view
        end
      end

      attr_reader :screenshotView

      def isShowingScreenshot
        screenshotContainerView.superview != nil
      end

      def updateScreenshot
        return unless webView
        return if isShowingScreenshot
        screenshot = webView.snapshotViewAfterScreenUpdates(false)
        return unless screenshot

        screenshotView.removeFromSuperview if screenshotView
        screenshot.translatesAutoresizingMaskIntoConstraints = false
        screenshotContainerView.addSubview(screenshot)

        NSLayoutConstraint.activateConstraints([
          screenshot.centerXAnchor.constraintEqualToAnchor(screenshotContainerView.centerXAnchor),
          screenshot.topAnchor.constraintEqualToAnchor(screenshotContainerView.topAnchor),
          screenshot.widthAnchor.constraintEqualToConstant(screenshot.bounds.size.width),
          screenshot.heightAnchor.constraintEqualToConstant(screenshot.bounds.size.height)
        ])
        @screenshotView = screenshot
      end

      def showScreenshot
        if !isShowingScreenshot && !isRefreshing
          addSubview(screenshotContainerView)
          addFillConstraintsForSubview(screenshotContainerView)
          showOrHideWebView
        end
      end

      def hideScreenshot
        screenshotContainerView.removeFromSuperview
        showOrHideWebView
      end

      def clearScreenshot
        screenshotView.removeFromSuperview if screenshotView
      end
    end
  end
end
