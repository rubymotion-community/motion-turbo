module Turbo
  # The WebViewBridge is an internal class used for bi-directional communication
  # with the web view/JavaScript
  class WebViewBridge
    attr_accessor :webView, :delegate, :pageLoadDelegate, :visitDelegate#, :navigationDelegate
    def initWithWebView(webView)
      @webView = webView
      setup

      self
    end

    private

    def setup
      messageHandlerName = "turbo"
      webView.configuration.userContentController.addUserScript(userScript)
      scriptMessageHandler = ScriptMessageHandler.alloc.initWithDelegate(self)
      webView.configuration.userContentController.addScriptMessageHandler(scriptMessageHandler, name: messageHandlerName)
    end

    def userScript
      url = self.class.bundle.URLForResource("turbo", withExtension: "js")
      source = NSString.stringWithContentsOfURL(url, encoding: NSUTF8StringEncoding, error: nil)
      WKUserScript.alloc.initWithSource(source, injectionTime: WKUserScriptInjectionTimeAtDocumentEnd, forMainFrameOnly: true)
    end

    def self.bundle
      @bundle ||= NSBundle.bundleForClass(self)
    end

    public

    def visitLocation(location, withOptions: options, restorationIdentifier: restorationIdentifier)
      raise unless options.is_a? Turbo::VisitOptions
      callJavaScriptFunction("window.turboNative.visitLocationWithOptionsAndRestorationIdentifier",
        withArguments: [
          location.absoluteString,
          options.encode,
          restorationIdentifier]
      )
    end

    def clearSnapshotCache
      callJavaScriptFunction("window.turboNative.clearSnapshotCache", withArguments: [])
    end

    def cancelVisitWithIdentifier(identifier)
      callJavaScriptFunction("window.turboNative.cancelVisitWithIdentifier", withArguments: [identifier])
    end

    # JavaScript Evaluation

    def callJavaScriptFunction(functionExpression, withArguments: arguments)
      callJavaScriptFunction(functionExpression, withArguments: arguments, completionHandler: nil)
    end

    def callJavaScriptFunction(functionExpression, withArguments: arguments, completionHandler: completionHandler)
      script = scriptForCallingJavaScriptFunction(functionExpression, withArguments: arguments)
      unless script
        NSLog("Error encoding arguments for JavaScript function `%@'", functionExpression)
        return
      end

      debugLog("[Bridge] → #{functionExpression} #{arguments}")

      webView.evaluateJavaScript(script, completionHandler: -> (result, error) {
        debugLog("[Bridge] = #{functionExpression} evaluation complete")

        if result
          if error = result["error"]
            stack = result["stack"]
            NSLog("Error evaluating JavaScript function `%@': %@\n%@", functionExpression, error, stack)
          else
            completionHandler.call(result["value"]) if completionHandler
          end
        elsif error
          delegate.webView(self, didFailJavaScriptEvaluationWithError: error) if delegate
        end
      })
    end

    def scriptForCallingJavaScriptFunction(functionExpression, withArguments: arguments)
      encodedArguments = encodeJavaScriptArguments(arguments)
      return unless encodedArguments

      script = "(function(result) {\n" +
               "  try {\n" +
               "    result.value = " + functionExpression + "(" + encodedArguments + ")\n" +
               "  } catch (error) {\n" +
               "    result.error = error.toString()\n" +
               "    result.stack = error.stack\n" +
               "  }\n" +
               "  return result\n" +
               "})({})"
      return script
    end

    def encodeJavaScriptArguments(arguments)
      arguments = arguments.map {|v| v.nil? ? NSNull.alloc.init() : v }

      data = NSJSONSerialization.dataWithJSONObject(arguments, options: 0, error: nil)
      if data
        dataString = NSString.alloc.initWithData(data, encoding: NSUTF8StringEncoding)
        return dataString[1..-2]
      end
      return nil
    end

    def scriptMessageHandlerDidReceiveMessage(message)
      message = ScriptMessage.parse(message)
      return unless message

      if message.name.to_sym != :log
        debugLog("[Bridge] ← #{message.name} #{message.data}")
      end

      case message.name.to_sym
      when :page_loaded
        pageLoadDelegate.webView(self, didLoadPageWithRestorationIdentifier: message.restorationIdentifier) if pageLoadDelegate
      when :page_load_failed
        delegate.webView(self, didFailInitialPageLoadWithError: TurboError.pageLoadFailure) if delegate
      when :form_submission_started
        delegate.webView(self, didStartFormSubmissionToLocation: message.location) if delegate
      when :form_submission_finished
        delegate.webView(self, didFinishFormSubmissionToLocation: message.location) if delegate
      when :page_invalidated
        delegate.webViewDidInvalidatePage(self) if delegate
      when :visit_proposed
        delegate.webView(self, didProposeVisitToLocation: message.location, withOptions: message.options) if delegate
      when :visit_started
        visitDelegate.webView(self, didStartVisitWithIdentifier: message.identifier, hasCachedSnapshot: message.data["hasCachedSnapshot"]) if visitDelegate
      when :visit_request_started
        visitDelegate.webView(self, didStartRequestForVisitWithIdentifier: message.identifier, date: message.date) if visitDelegate
      when :visit_request_completed
        visitDelegate.webView(self, didCompleteRequestForVisitWithIdentifier: message.identifier) if visitDelegate
      when :visit_request_failed
        visitDelegate.webView(self, didFailRequestForVisitWithIdentifier: message.identifier, statusCode: message.data["statusCode"]) if visitDelegate
      when :visit_request_finished
        visitDelegate.webView(self, didFinishRequestForVisitWithIdentifier: message.identifier, date: message.date) if visitDelegate
      when :visit_rendered
        visitDelegate.webView(self, didRenderForVisitWithIdentifier: message.identifier) if visitDelegate
      when :visit_completed
        visitDelegate.webView(self, didCompleteVisitWithIdentifier: message.identifier, restorationIdentifier: message.restorationIdentifier) if visitDelegate
      when :error_raised
        error = message.data["error"] || "<unknown error>"
        debugLog("JavaScript error: #{error}")
      when :log
        msg = message.data["message"]
        debugLog("[Bridge] ← log: #{msg}") if msg.is_a?(String)
      end
    end
  end
end
