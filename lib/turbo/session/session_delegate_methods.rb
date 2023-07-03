module Turbo
  class Session
    module SessionDelegateMethods

      def sessionDidLoadWebView(session)
        session.webView.navigationDelegate = session
      end

      def session(session, openExternalURL: url)
        UIApplication.shared.open(url)
      end

      def sessionDidStartRequest(session)
      end

      def sessionDidFinishRequest(session)
      end

      def sessionDidStartFormSubmission(session)
      end

      def sessionDidFinishFormSubmission(session)
      end

      def session(session, didReceiveAuthenticationChallenge: challenge, &completionHandler)
        completionHandler.call(NSURLAuthenticationChallengeSender.performDefaultHandlingForAuthenticationChallenge, nil)
      end
    end
  end
end
