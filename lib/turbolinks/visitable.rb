module Turbolinks
  module Visitable
    attr_accessor :visitableDelegate
    attr_reader :visitableView, :visitableURL

    def visitableDidRender
      puts "Visitable#visitableDidRender"
      self.title = visitableView.webView.title if visitableView.webView
    end

    def reloadVisitable
      puts "Visitable#reloadVisitable"
      visitableDelegate.visitableDidRequestReload(self) if visitableDelegate
    end

    def activateVisitableWebView(webView)
      puts "Visitable#activateVisitableWebView"
      visitableView.activateWebView(webView, forVisitable: self)
    end

    def deactivateVisitableWebView
      puts "Visitable#deactivateVisitableWebView"
      visitableView.deactivateWebView
    end

    def showVisitableActivityIndicator
      puts "Visitable#showVisitableActivityIndicator"
      visitableView.showActivityIndicator
    end

    def hideVisitableActivityIndicator
      puts "Visitable#hideVisitableActivityIndicator"
      visitableView.hideActivityIndicator
    end

    def updateVisitableScreenshot
      puts "Visitable#updateVisitableScreenshot"
      visitableView.updateScreenshot
    end

    def showVisitableScreenshot
      puts "Visitable#showVisitableScreenshot"
      visitableView.showScreenshot
    end

    def hideVisitableScreenshot
      puts "Visitable#hideVisitableScreenshot"
      visitableView.hideScreenshot
    end

    def clearVisitableScreenshot
      puts "Visitable#clearVisitableScreenshot"
      visitableView.clearScreenshot
    end

    def visitableWillRefresh
      puts "Visitable#visitableWillRefresh"
      visitableView.refreshControl.beginRefreshing
    end

    def visitableDidRefresh
      puts "Visitable#visitableDidRefresh"
      visitableView.refreshControl.endRefreshing
    end

    def visitableViewDidRequestRefresh
      puts "Visitable#visitableViewDidRequestRefresh"
      visitableDelegate?.visitableDidRequestRefresh(self)
    end
  end
end
