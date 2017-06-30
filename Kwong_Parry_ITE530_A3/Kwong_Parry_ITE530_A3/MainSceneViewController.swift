

import UIKit
import CoreData

class MainSceneViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var entries:[Entry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
        tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //segue to selected item view and pass cell items
        
        if segue.identifier == "detailSegue",
            let detailVC = segue.destination as? EntryViewController,
            let index = tableView.indexPathForSelectedRow?.row
        {
            detailVC.indexPath = index
        }
        
        
    }
    
    
    func getData(){ //retrieve Core Data
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        do{
            
            entries = try context.fetch(Entry.fetchRequest())
            
        } catch { //set sample entry for display
            
            setSampleEntry()
        }

    }
    
    func setSampleEntry(){
        
        let photo1 = UIImage(named: "spanishResto")
        let photo2 = UIImage(named: "chorizo")
        let photo3 = UIImage(named: "tortilla")
        
        //storing core data
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let newEntry = Entry(context: context)
        
        let imgData: NSData = UIImagePNGRepresentation(photo1!)! as NSData
        let imgData2: NSData = UIImagePNGRepresentation(photo2!)! as NSData
        let imgData3: NSData = UIImagePNGRepresentation(photo3!)! as NSData
        
        newEntry.image = imgData
        newEntry.image2 = imgData2
        newEntry.image3 = imgData3
        newEntry.restaurantName = "Cascal"
        newEntry.review = "The tapas was great! Lovely atmosphere and wonderful service :)"
        newEntry.rating = 4.0
        newEntry.lat = 37.3912
        newEntry.long = 122.0810
        
        appDelegate.saveContext()
    }
    
    //MARK: UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return entries.count //sets table rows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{ //creates rzeusable cell and assigns cell items

        //set up cell by assigning photo, rating and name
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let entry = entries[indexPath.row]
        
        cell.nameLabel?.text = entry.restaurantName
        cell.ratingView.rating = Int(entry.rating)
        
        if let imgData = entry.image{ //check to see if there is image stored
            cell.myImage.image = UIImage(data: imgData as Data)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete an entry and update Core Data
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if editingStyle == .delete{
            let entry = entries[indexPath.row]
            context.delete(entry)
            appDelegate.saveContext()
            
            do{
                entries = try context.fetch(Entry.fetchRequest())
            } catch {
                print("Fetch Failed")
            }
        }
        tableView.reloadData() //reload table
    }
    
    
}

