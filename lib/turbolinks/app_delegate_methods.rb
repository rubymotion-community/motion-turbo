module Turbolinks
  module AppDelegateMethods
    # TODO: this is our own API, it should be more rubyish
    def presentVisitableForSession(session, URL: url, action: action)
      puts "AppDelegate#presentVisitableForSession:URL:action"
      action ||= :advance
      visitable = Turbolinks::VisitableViewController.new(url: url)
    
      # TODO: can't assume @navigationController instance variable
      if action == :advance
        @navigationController.pushViewController(visitable, animated: true)
      elsif action == :replace
        @navigationController.popViewControllerAnimated(false)
        @navigationController.pushViewController(visitable, animated: false)
      end

      session.visit(visitable)
    end

    # Required Turbolinks delegate method
    def session(session, didProposeVisitToURL: url, withAction: action)
      puts "AppDelegate#session:didProposeVisitToURL:withAction url: #{url.to_s} action: #{action}"
      if self.respond_to?(:will_visit)
        will_visit(url, action)
      else
        presentVisitableForSession(session, URL: url, action: action)
      end
    end

    # optional delegate method
    def sessionDidStartRequest(session)
      # puts "AppDelegate#sessionDidStartRequest"
      UIApplication.sharedApplication.networkActivityIndicatorVisible = true
    end
    
    # optional delegate method
    def sessionDidFinishRequest(session)
      # puts "AppDelegate#sessionDidFinishRequest"
      UIApplication.sharedApplication.networkActivityIndicatorVisible = false
    end
  end
end
