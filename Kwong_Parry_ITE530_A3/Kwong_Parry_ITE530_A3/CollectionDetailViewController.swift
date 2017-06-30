import UIKit

class CollectionDetailViewController: UIViewController {
 
    //MARK: Properties
    @IBOutlet weak var photoImageEnlarged: UIImageView!
    
    var theImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageEnlarged.image = theImage //sets enlarged image
    }
    
}

extension CollectionDetailViewController : ZoomingViewController //extension for zoom animation of image
{
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return photoImageEnlarged
    }
}

