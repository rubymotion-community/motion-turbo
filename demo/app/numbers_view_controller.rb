# A simple native table view controller to demonstrate loading non-Turbo screens
# for a visit proposal
class NumbersViewController < UITableViewController

  attr_accessor :url

  def viewDidLoad
    super
    title = "Numbers"
    tableView.registerClass(UITableViewCell, forCellReuseIdentifier: "Cell")
  end

  def numberOfSections(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    100
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier("Cell", for: indexPath)

    number = indexPath.row + 1
    cell.textLabel.text = "Row #{number}" if cell.textLabel
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    turboNavController = navigationController
    u = url.URLByAppendingPathComponent("#{indexPath.row + 1}")
    turboNavController.push(url.URLByAppendingPathComponent("#{indexPath.row + 1}"))
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  end
end
