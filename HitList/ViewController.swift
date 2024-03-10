//
//  ViewController.swift
//  HitList
//
//  Created by Vinod Supnekar on 04/03/24.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var people: [NSManagedObject] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        
        let managedObectContext = appDelegate.persistentContainer.viewContext
        // viewContext :- attached with Main Queue.
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            
            //Fetch In two ways:-
            // 1
//            people = try managedObectContext.fetch(fetchRequest)
            
            //OR
            //2
            try managedObectContext.performAndWait {
                people = try fetchRequest.execute()
            }
           
            
        } catch let error as NSError {
            print("could not fetch , got \(error), \(error.userInfo)")
        }
        
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    @IBAction func addName(_ sender: UIBarButtonItem) {
      
        let alert = UIAlertController(title: "name",
                                      message: "add a name",
                                      preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
            [unowned self] action in
                                             
               guard let textField = alert.textFields?.first,
                 let nameToSave = textField.text else {
                   return
               }
               
               self.save(name: nameToSave)
               self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                          style: .cancel)
         
         alert.addTextField()
         
         alert.addAction(saveAction)
         alert.addAction(cancelAction)
         
         present(alert, animated: true)
        
    }

    func save(name: String) {
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      // 1
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      // 2
      let entity =
        NSEntityDescription.entity(forEntityName: "Person",
                                   in: managedContext)!
      
      let person = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      
      // 3
      person.setValue(name, forKeyPath: "name")
      
      // 4
      do {
        try managedContext.save()
        people.append(person)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }


}


extension ViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
      func tableView(_ tableView: UITableView,
                     numberOfRowsInSection section: Int) -> Int {
        return people.count
      }

      func tableView(_ tableView: UITableView,
                     cellForRowAt indexPath: IndexPath)
                     -> UITableViewCell {

        let person = people[indexPath.row]
        let cell =
          tableView.dequeueReusableCell(withIdentifier: "Cell",
                                        for: indexPath)
        cell.textLabel?.text =
          person.value(forKeyPath: "name") as? String
        return cell
      }

}
