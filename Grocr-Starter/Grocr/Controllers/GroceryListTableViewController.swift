/// Copyright (c) 2018 Razeware LLC

import UIKit
import Firebase

class GroceryListTableViewController: UITableViewController {

  // MARK: Constants
  let listToUsers = "ListToUsers"
  let ref = Database.database().reference(withPath: "grocery-items")
    
  // MARK: Properties
  var items: [GroceryItem] = []
  var user: User!
  var userCountBarButtonItem: UIBarButtonItem!
    //let ref = Database.database().reference(withPath: "grocery-items")
  
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: UIViewController Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.allowsMultipleSelectionDuringEditing = false
    
    userCountBarButtonItem = UIBarButtonItem(title: "1",
                                             style: .plain,
                                             target: self,
                                             action: #selector(userCountButtonDidTouch))
    userCountBarButtonItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = userCountBarButtonItem
    
    user = User(uid: "FakeId", email: "hungry@person.food")
    
//    ref.observe(.value, with: { snapshot in
//        var newItems: [GroceryItem] = []
//        // 3
//        for child in snapshot.children {
//            // 4
//            if let snapshot = child as? DataSnapshot,
//                let groceryItem = GroceryItem(snapshot: snapshot) {
//                newItems.append(groceryItem)
//            }
//        }
//
//        // 5
//        self.items = newItems
//        self.tableView.reloadData()
//    })
    ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
        var newItems: [GroceryItem] = []
        for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
                let groceryItem = GroceryItem(snapshot: snapshot) {
                newItems.append(groceryItem)
            }
        }
        
        self.items = newItems
        self.tableView.reloadData()
    })
  }
  
  // MARK: UITableView Delegate methods
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
    let groceryItem = items[indexPath.row]
    
    cell.textLabel?.text = groceryItem.name
    cell.detailTextLabel?.text = groceryItem.addedByUser
    
    toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//    if editingStyle == .delete {
//      items.remove(at: indexPath.row)
//      tableView.reloadData()
//    }
    if editingStyle == .delete {
        let groceryItem = items[indexPath.row]
        groceryItem.ref?.removeValue()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    guard let cell = tableView.cellForRow(at: indexPath) else { return }
//    var groceryItem = items[indexPath.row]
//    let toggledCompletion = !groceryItem.completed
//
//    toggleCellCheckbox(cell, isCompleted: toggledCompletion)
//    groceryItem.completed = toggledCompletion
//    tableView.reloadData()
    // 1
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    // 2
    let groceryItem = items[indexPath.row]
    // 3
    let toggledCompletion = !groceryItem.completed
    // 4
    toggleCellCheckbox(cell, isCompleted: toggledCompletion)
    // 5
    groceryItem.ref?.updateChildValues([
        "completed": toggledCompletion
        ])
  }
  
  func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
    if !isCompleted {
      cell.accessoryType = .none
      cell.textLabel?.textColor = .black
      cell.detailTextLabel?.textColor = .black
    } else {
      cell.accessoryType = .checkmark
      cell.textLabel?.textColor = .gray
      cell.detailTextLabel?.textColor = .gray
    }
  }
  
  // MARK: Add Item
  
  @IBAction func addButtonDidTouch(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Grocery Item",
                                  message: "Add an Item",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
//      let textField = alert.textFields![0]
//
//      let groceryItem = GroceryItem(name: textField.text!,
//                                    addedByUser: self.user.email,
//                                    completed: false)
//
//        self.items.append(groceryItem)
//        self.tableView.reloadData()

        // 1
        guard let textField = alert.textFields?.first,
            let text = textField.text else { return }
        
        // 2
        let groceryItem = GroceryItem(name: text,
                                      addedByUser: self.user.email,
                                      completed: false)
        // 3
        let groceryItemRef = self.ref.child(text.lowercased())
        
        // 4
        groceryItemRef.setValue(groceryItem.toAnyObject())
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel)
    
    alert.addTextField()
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  @objc func userCountButtonDidTouch() {
    performSegue(withIdentifier: listToUsers, sender: nil)
  }
}
