
import UIKit
import CoreLocation
import MapKit
import CoreData

private let reuseIdentifier = "Cell"

class EntryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    //MARK: Properties
    @IBOutlet weak var restoName: UILabel!
    @IBOutlet weak var review: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var collectionView: UICollectionView!

    var imageArray: [UIImage?] = []
    var indexPath: Int = 0
    var entries:[Entry] = []
    var annotation = MKPointAnnotation()
    var selectedIndexPath: IndexPath!
    
    let collectionViewManager = UICollectionViewController()
    let manager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData() //retreive Core Data
        
        let entry = entries[indexPath]
        
        //convert images
        let photo1 = convertImage(imgData: entry.image)
        let photo2 = convertImage(imgData: entry.image2)
        let photo3 = convertImage(imgData: entry.image3)
        
        //add Images to imageArray
        addImage(image: photo1)
        addImage(image: photo2)
        addImage(image: photo3)
        
        //assign map coordinates to annotation and add to map
        if (entry.lat != 0.0 && entry.long != 0.0){
            
            annotation.coordinate.longitude = entry.long
            annotation.coordinate.latitude = entry.lat
            map.addAnnotation(annotation)
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(annotation.coordinate, span)
            map.setRegion(region, animated: true)
        }
        
        //assign remaining entry values
        restoName.text = entry.restaurantName
        review.text = entry.review
        ratingControl.rating = Int(entry.rating)
        
        //set up collection view delegate and location manager
        collectionView.delegate = self
        collectionView.dataSource = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func convertImage(imgData: NSData?) -> UIImage?{ //convert imageData to UIImage
    
        if let data = imgData{
            
            let photo = UIImage(data: data as Data)
            return photo!
            
        }
        return nil
    }
    
    func addImage(image: UIImage?){
        
        if image != nil{
            imageArray.append(image!)
        }
    }
    
    func getData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        do{
            
            entries = try context.fetch(Entry.fetchRequest())
        } catch {
            
            print("Fetch Failed")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //segue to detail view of image
        
        if segue.identifier == "ShowDetail",
            let detailImageView = segue.destination as? CollectionDetailViewController
        {
            detailImageView.theImage = sender as! UIImage
            
        }
    }

    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageArray.count //number of items in collection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt inPath: IndexPath) -> UICollectionViewCell {
        
        //set up collection view cell for images to be placed
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: inPath) as! CollectionViewCell
        
        if let image = imageArray[inPath.row]{
            cell.photoImage.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //find the image for each indexPath
        let image = imageArray[indexPath.item]
        
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "ShowDetail", sender: image) //perform segue and send cell image
    }
}


//MARK: Extensions

extension EntryViewController: CLLocationManagerDelegate{
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {  //Tells delegate authorization status changed
        
        if status ==  .authorizedWhenInUse{
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("error:: \(error)")
    }
}

extension EntryViewController: ZoomingViewController {  //extension for zoom animation of image
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        if let indexPath = selectedIndexPath{
            let cell = collectionView?.cellForItem(at: indexPath) as! CollectionViewCell
            return cell.photoImage
        }
        return nil
    }
}

