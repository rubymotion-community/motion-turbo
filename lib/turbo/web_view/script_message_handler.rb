module Turbo
  # This class prevents retain cycle caused by WKUserContentController
  class ScriptMessageHandler

    attr_accessor :delegate

    def initWithDelegate(delegate)
      self.delegate = delegate
      self
    end

    def userContentController(userContentController, didReceiveScriptMessage: message)
      delegate.scriptMessageHandlerDidReceiveMessage(message) if delegate
    end
  end
end
