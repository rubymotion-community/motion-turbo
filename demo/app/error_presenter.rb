module ErrorPresenter
  def presentError(error, &handler)
    errorViewController = ErrorViewController.new
    # TODO
    errorViewController.configure(with: error) do
      self.removeErrorViewController(errorViewController)
      handler.call
    end

    errorView = errorViewController.view
    errorView.translatesAutoresizingMaskIntoConstraints = false

    addChildViewController(errorViewController)
    view.addSubview(errorView)
    NSLayoutConstraint.activateConstraints([
        errorView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
        errorView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
        errorView.topAnchor.constraintEqualToAnchor(view.topAnchor),
        errorView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
    ])
    errorViewController.didMoveToParentViewController(self)
  end

  protected

  def removeErrorViewController(errorViewController)
    errorViewController.willMoveToParentViewController(nil)
    errorViewController.view.removeFromSuperview
    errorViewController.removeFromParentViewController
  end
end

class ErrorViewController < UIViewController

    attr_accessor :handler

    def viewDidLoad
      super
      setup
    end

    def setup
      view.backgroundColor = UIColor.systemBackgroundColor

      vStack = UIStackView.alloc.initWithArrangedSubviews([imageView, titleLabel, bodyLabel, button])
      vStack.translatesAutoresizingMaskIntoConstraints = false
      vStack.axis = UILayoutConstraintAxisVertical
      vStack.spacing = 16
      vStack.alignment = UIStackViewAlignmentCenter

      view.addSubview(vStack)
      NSLayoutConstraint.activateConstraints([
        vStack.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
        vStack.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
        vStack.leadingAnchor.constraintGreaterThanOrEqualToAnchor(view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
        vStack.trailingAnchor.constraintLessThanOrEqualToAnchor(view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
      ])
    end

    def configure(error, &handler)
      titleLabel.text = "Error loading page"
      self.handler = handler
    end

    def performAction(sender)
      handler.call if handler
    end

    private

    # MARK: - Views

    def imageView
      return @imageView if @imageView
      configuration = UIImageSymbolConfiguration.configurationWithPointSize(38, weight: UIImageSymbolWeightSemibold)
      image = UIImage.systemImageNamed("exclamationmark.triangle", withConfiguration: configuration)
      imageView = UIImageView.alloc.initWithImage(image)
      imageView.translatesAutoresizingMaskIntoConstraints = false
      @imageView = imageView
    end

    def titleLabel
      return @titleLabel if @titleLabel
      label = UILabel.new
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleLargeTitle)
      label.textAlignment = NSTextAlignmentCenter
      @titleLabel = label
    end

    def bodyLabel
      return @bodyLabel if @bodyLabel
      label = UILabel.new
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
      label.textAlignment = NSTextAlignmentCenter
      label.numberOfLines = 0
      @bodyLabel = label
    end

    def button
      return @button if @button
      button = UIButton.buttonWithType(UIButtonTypeSystem)
      button.setTitle("Retry", forState: UIControlStateNormal)
      button.addTarget(self, action: :"performAction:", forControlEvents: UIControlEventTouchUpInside)
      button.titleLabel.font = UIFont.boldSystemFontOfSize(17) if button.titleLabel
      @button = button
    end
end
