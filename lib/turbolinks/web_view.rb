module Turbolinks
  class WebView < WKWebView
    attr_accessor :delegate, :pageLoadDelegate, :visitDelegate#, :navigationDelegate

    def initWithConfiguration(configuration)
      initWithFrame(CGRectZero, configuration: configuration)

      bundle = NSBundle.bundleForClass(self)
      source = NSString.stringWithContentsOfURL(bundle.URLForResource("WebView", withExtension: "js"), encoding: NSUTF8StringEncoding, error: nil)
      userScript = WKUserScript.alloc.initWithSource(source, injectionTime: WKUserScriptInjectionTimeAtDocumentEnd, forMainFrameOnly: true)
      configuration.userContentController.addUserScript(userScript)
      configuration.userContentController.addScriptMessageHandler(self, name: "turbolinks")

      self.translatesAutoresizingMaskIntoConstraints = false
      scrollView.decelerationRate = UIScrollViewDecelerationRateNormal

      self
    end

    def visitLocation(location, withAction: action, restorationIdentifier: restorationIdentifier)
      puts "WebView#visitLocation:location:withAction:restorationIdentifier"
      callJavaScriptFunction("webView.visitLocationWithActionAndRestorationIdentifier", withArguments: [location.absoluteString, action, restorationIdentifier])
    end

    def issueRequestForVisitWithIdentifier(identifier)
      puts "WebView#issueRequestForVisitWithIdentifier"
      callJavaScriptFunction("webView.issueRequestForVisitWithIdentifier", withArguments: [identifier])
    end

    def changeHistoryForVisitWithIdentifier(identifier)
      puts "WebView#changeHistoryForVisitWithIdentifier"
      callJavaScriptFunction("webView.changeHistoryForVisitWithIdentifier", withArguments: [identifier])
    end

    def loadCachedSnapshotForVisitWithIdentifier(identifier)
      puts "WebView#loadCachedSnapshotForVisitWithIdentifier"
      callJavaScriptFunction("webView.loadCachedSnapshotForVisitWithIdentifier", withArguments: [identifier])
    end

    def loadResponseForVisitWithIdentifier(identifier)
      puts "WebView#loadResponseForVisitWithIdentifier"
      callJavaScriptFunction("webView.loadResponseForVisitWithIdentifier", withArguments: [identifier])
    end

    def cancelVisitWithIdentifier(identifier)
      puts "WebView#cancelVisitWithIdentifier"
      callJavaScriptFunction("webView.cancelVisitWithIdentifier", withArguments: [identifier])
    end

    # JavaScript Evaluation

    def callJavaScriptFunction(functionExpression, withArguments: arguments)
      puts "WebView#callJavaScriptFunction:withArguments"
      callJavaScriptFunction(functionExpression, withArguments: arguments, completionHandler: nil)
    end

    def callJavaScriptFunction(functionExpression, withArguments: arguments, completionHandler: completionHandler)
      puts "WebView#callJavaScriptFunction:withArguments:completionHandler"
      script = scriptForCallingJavaScriptFunction(functionExpression, withArguments: arguments)
      unless script
        NSLog("Error encoding arguments for JavaScript function `%@'", functionExpression)
        return
      end

      evaluateJavaScript(script, completionHandler: -> (result, error) {
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
      puts "WebView#scriptForCallingJavaScriptFunction:withArguments"
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
      puts "WebView#encodeJavaScriptArguments"
      arguments = arguments.map {|v| v.nil? ? NSNull.alloc.init() : v }

      data = NSJSONSerialization.dataWithJSONObject(arguments, options: 0, error: nil)
      if data
        dataString = NSString.alloc.initWithData(data, encoding: NSUTF8StringEncoding)
        return dataString[1..-2]
      end
      return nil
    end

    # WKScriptMessageHandler

    def userContentController(userContentController, didReceiveScriptMessage: message)
      puts "WebView#userContentController:didReceiveScriptMessage"
      message = ScriptMessage.parse(message)
      return unless message

      puts "message.name: #{message.name}"
      case message.name
      when :page_loaded
        pageLoadDelegate.webView(self, didLoadPageWithRestorationIdentifier: message.restorationIdentifier) if pageLoadDelegate
      when :page_invalidated
        delegate.webViewDidInvalidatePage(self) if delegate
      when :visit_proposed
        delegate.webView(self, didProposeVisitToLocation: message.location, withAction: message.action) if delegate
      when :visit_started
        visitDelegate.webView(self, didStartVisitWithIdentifier: message.identifier, hasCachedSnapshot: message.data["hasCachedSnapshot"]) if visitDelegate
      when :visit_request_started
        visitDelegate.webView(self, didStartRequestForVisitWithIdentifier: message.identifier) if visitDelegate
      when :visit_request_completed
        visitDelegate.webView(self, didCompleteRequestForVisitWithIdentifier: message.identifier) if visitDelegate
      when :visit_request_failed
        visitDelegate.webView(self, didFailRequestForVisitWithIdentifier: message.identifier, statusCode: message.data["statusCode"]) if visitDelegate
      when :visit_request_finished
        visitDelegate.webView(self, didFinishRequestForVisitWithIdentifier: message.identifier) if visitDelegate
      when :visit_rendered
        visitDelegate.webView(self, didRenderForVisitWithIdentifier: message.identifier) if visitDelegate
      when :visit_completed
        visitDelegate.webView(self, didCompleteVisitWithIdentifier: message.identifier, restorationIdentifier: message.restorationIdentifier) if visitDelegate
      when :error_raised
        error = message.data["error"] || "<unknown error>"
        NSLog("JavaScript error: %@", error)
      end
    end
  end
end
