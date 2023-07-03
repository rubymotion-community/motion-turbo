class AppDelegate

  def application(application, didFinishLaunchingWithOptions: launchOptions)
    true
  end

  # MARK: UISceneSession Lifecycle

  def application(application, configurationForConnecting: connectingSceneSession, options: options)
    UISceneConfiguration.allow.initWithName("Default Configuration", sessionRole: connectingSceneSession.role)
  end
end
