//
//  TableViewController.swift
//  SHResponsiveLabel
//
//  Created by hsusmita on 11/08/15.
//  Copyright (c) 2015 hsusmita.com. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
  var expandedIndexPaths = [NSIndexPath]()

  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 100.0
  }
}

extension TableViewController: UITableViewDataSource,ExpandableCellDelegate {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("customCell") as! ExpandableCell
    var str = "A long text with #hashTag text, with @username and URL http://www.google.com "
 
    for (var i = 0 ; i < indexPath.row ; i++) {
      str = str + " A long text\n"
    }
    cell.configureCell(str, shouldExpand: (find(expandedIndexPaths, indexPath) != nil))
    cell.delegate = self
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if find(expandedIndexPaths, indexPath) == nil {
      return 80.0
    }else {
      return UITableViewAutomaticDimension
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  func didTapOnMoreButton(cell: ExpandableCell) {
    let indexPath = self.tableView.indexPathForCell(cell)
    if find(expandedIndexPaths, indexPath!) == nil {
      expandedIndexPaths.append(indexPath!)
    }else {
      var index = find(expandedIndexPaths, indexPath!)
      expandedIndexPaths.removeAtIndex(index!)
    }
    if let path = indexPath {
      tableView.reloadRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
  }
}

extension TableViewController: UITableViewDelegate {

}
