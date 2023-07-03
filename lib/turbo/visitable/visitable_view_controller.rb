module Turbo
  class VisitableViewController < UIViewController
    include Visitable

    attr_accessor :visitableDelegate
    attr_reader :visitableURL

    def initWithURL(url)
      if url.is_a? String
        url = NSURL.alloc.initWithString(url)
      end
      @visitableURL = url
      self
    end

    # View Lifecycle methods

    def viewDidLoad
      super
      installVisitableView
    end

    def viewWillAppear(animated)
      super
      visitableDelegate.visitableViewWillAppear(self) if visitableDelegate
    end

    def viewDidAppear(animated)
      super
      visitableDelegate.visitableViewDidAppear(self) if visitableDelegate
    end

    # Visitable

    def visitableDidRender
      self.title = visitableView.webView.title if visitableView.webView
    end

    def showVisitableActivityIndicator
      visitableView.showActivityIndicator
    end

    def hideVisitableActivityIndicator
      visitableView.hideActivityIndicator
    end

    # Visitable View

    def visitableView
      @visitableView ||= begin
        view = VisitableView.alloc.initWithFrame(CGRectZero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view
      end
    end

    private

    def installVisitableView
      view.addSubview(visitableView)
      #view.insertSubview(visitableView, atIndex: 0)
      self.edgesForExtendedLayout = UIRectEdgeAll # TODO document fix for fullscre
      NSLayoutConstraint.activateConstraints([
        visitableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
        visitableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
        visitableView.topAnchor.constraintEqualToAnchor(view.topAnchor),
        visitableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
      ])
    end
  end
end
