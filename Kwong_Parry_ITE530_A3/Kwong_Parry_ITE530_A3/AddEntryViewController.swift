
import UIKit
import MapKit
import CoreData

class AddEntryViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {


    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    var imagePicked = 0
    var imagePicker = UIImagePickerController()
    let manager = CLLocationManager()
    var annotationStore: MKPointAnnotation? = nil
    var coordinateLong: Double = 0.0
    var coordinateLat: Double = 0.0
    let starRating = 1.0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        textView.delegate = self
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        
    }
    
    @IBAction func unWindToAddEntry(unwindSegue: UIStoryboardSegue){ //unwind segue
    
    
    }
    
    
    @IBAction func clickButton(_ sender: UIButton) { //button click manager
    
        if (sender.tag < 3){
        
            imagePicked = sender.tag
        
            let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                    self.present(self.imagePicker, animated: true)
                } else {
                    self.cameraNotAvailable()
                }
            }))
        
            actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action: UIAlertAction) in
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(self.imagePicker, animated: true)}))
        
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
            self.present(actionSheet, animated: true, completion: nil)
        
        } else if (sender.tag == 3){

            
        } else if (sender.tag == 4){
            
            saveItem()
            print("clicked")
            navigationController!.popViewController(animated: true)

        }
    
    }
    
    func saveItem(){ //save Entry
        
        //update rating
        let starRating = ratingControl.rating
        
        //storing core data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
        let context = appDelegate.persistentContainer.viewContext
        
        let newEntry = Entry(context: context)
        
        //convert image to NSData for Binary Data storage
        let imgData: NSData? = myImageView.convertImage(imageView: myImageView)
        let imgData2: NSData? = imageView2.convertImage(imageView: imageView2)
        let imgData3: NSData? = imageView3.convertImage(imageView: imageView3)
        
        
        //assign to Core Data
        newEntry.image = imgData
        newEntry.image2 = imgData2
        newEntry.image3 = imgData3
        newEntry.restaurantName = nameTextField.text
        newEntry.review = textView.text
        newEntry.rating = Double(starRating)
        
        if let mapAnnotation = annotationStore{ //check for map annotation
            
            coordinateLong = mapAnnotation.coordinate.longitude
            coordinateLat = mapAnnotation.coordinate.latitude
        }
        newEntry.lat = coordinateLat
        newEntry.long = coordinateLong

        appDelegate.saveContext()

    }
    
   
    
    func dropPin(annotation: MKPointAnnotation) { //drop pin when transitioning back from map view
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05,0.05)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        mapView.setRegion(region, animated: true)
        annotationStore = annotation

    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        //check for the pickedImage and assign to the appropriate imageView
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            switch (imagePicked) {
            
            case 0:
                myImageView.image = pickedImage
            case 1:
                imageView2.image = pickedImage
            case 2:
                imageView3.image = pickedImage
            default:
                break
            }
            
        }
        else {
            errorMessage()
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func cameraNotAvailable(){ //camera not found alert message
        
        let noCameraAlert = UIAlertController(title: "Sorry", message: "Camera not found", preferredStyle: .alert)
        noCameraAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(noCameraAlert, animated: true, completion: nil)
    }
    
    func errorMessage(){ //Image selection error alert message
        
        let noImageAlert = UIAlertController(title: "Sorry", message: "Image couldn't be selected", preferredStyle: .alert)
        noImageAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(noImageAlert, animated: true, completion: nil)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: Extensions

extension AddEntryViewController: CLLocationManagerDelegate{

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) { //Tells delegate authorization status changed
        
        if status ==  .authorizedWhenInUse{
            manager.requestLocation() //Request user location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            
                //get updated User Location and display on map
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: location.coordinate, span:span)
                mapView.setRegion(region, animated: true)
        
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("error:: \(error)")
    }
}

extension UIImageView {
    
    func convertImage (imageView: UIImageView) -> NSData? { //convert image to NSData for Core Data storage
        
        if (imageView.image != nil){
         
            let imgData: NSData = UIImagePNGRepresentation(imageView.image!)! as NSData
            
            return imgData
        }
        return nil
    }
}

extension UITextField
{
    open override func draw(_ rect: CGRect) {
        
        self.layer.cornerRadius = 3.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true
    }
}

extension UITextView
{
    func textViewDidChange(_ textView: UITextView){
        
        //expand text view to fit text size
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
    }

}


