module Turbo
  module Visitable
    attr_accessor :visitableDelegate
    attr_reader :visitableView, :visitableURL

    def reloadVisitable
      visitableDelegate.visitableDidRequestReload(self) if visitableDelegate
    end

    def showVisitableActivityIndicator
      visitableView.showActivityIndicator
    end

    def hideVisitableActivityIndicator
      visitableView.hideActivityIndicator
    end

    def activateVisitableWebView(webView)
      visitableView.activateWebView(webView, forVisitable: self)
    end

    def deactivateVisitableWebView
      visitableView.deactivateWebView
    end

    def updateVisitableScreenshot
      visitableView.updateScreenshot
    end

    def showVisitableScreenshot
      visitableView.showScreenshot
    end

    def hideVisitableScreenshot
      visitableView.hideScreenshot
    end

    def clearVisitableScreenshot
      visitableView.clearScreenshot
    end

    def visitableWillRefresh
      visitableView.refreshControl.beginRefreshing
    end

    def visitableDidRefresh
      visitableView.refreshControl.endRefreshing
    end

    def visitableViewDidRequestRefresh
      visitableDelegate.visitableDidRequestRefresh(self) if visitableDelegate
    end

    def visitableViewController
      self
    end
  end
end
