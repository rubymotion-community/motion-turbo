module Turbolinks
  class VisitableViewController < UIViewController
    include Visitable

    # attr_accessor :visitableDelegate
    # attr_reader :visitableURL

    def initialize(options)
      url = options[:url]
      if url.is_a? String
        url = NSURL.alloc.initWithString(url)
      end
      @visitableURL = url
    end

    # Visitable View

    def visitableView
      @visitableView ||= begin
        view = VisitableView.alloc.initWithFrame(CGRectZero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view
      end
    end

    private def installVisitableView
      puts "VisitableViewController#installVisitableView"
      view.addSubview(visitableView)
      view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: 0, metrics: nil, views: { "view" => visitableView }))
      view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: 0, metrics: nil, views: { "view" => visitableView }))
    end

    # Visitable

    # def visitableDidRender
    #   puts "VisitableViewController#visitableDidRender"
    #   self.title = visitableView.webView.title if visitableView.webView
    # end

    # View Lifecycle methods

    def viewDidLoad
      puts "VisitableViewController#viewDidLoad"
      super # is this necessary?
      view.backgroundColor = UIColor.whiteColor
      installVisitableView
    end

    def viewWillAppear(animated)
      puts "VisitableViewController#viewWillAppear"
      super # is this necessary?
      visitableDelegate.visitableViewWillAppear(self) if visitableDelegate
    end

    def viewDidAppear(animated)
      puts "VisitableViewController#viewDidAppear"
      super # is this necessary?
      visitableDelegate.visitableViewDidAppear(self) if visitableDelegate
    end
  end
end
