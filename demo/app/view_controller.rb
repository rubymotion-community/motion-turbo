class ViewController < Turbo::VisitableViewController

  include ErrorPresenter

  def viewDidLoad
    super
    navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeMinimal
    view.backgroundColor = UIColor.systemBackgroundColor

    if presentingViewController != nil
      navigationItem.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target: self, action: "dismissModal")
    end
    true
  end

  def dismissModal
    dismissModalViewControllerAnimated(true)
  end
end
