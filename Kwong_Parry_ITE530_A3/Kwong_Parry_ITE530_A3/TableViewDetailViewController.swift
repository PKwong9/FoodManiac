import UIKit

class TableViewDetailViewController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var yearWorked: UILabel!
    @IBOutlet weak var tableCompany: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var yConstraintLogo: NSLayoutConstraint!
    
    var companyName = String()
    var yearOfWork = String()
    var imageString = String()
    var indexPath = 0
    var backgroundImagePath = String()

    
    override func viewWillAppear(_ animated: Bool) {
        
        switch (UIDevice.current.orientation.isLandscape) { //sets background image
        case (true):
            background.isHidden = true
            yConstraintLogo.constant = -20
        case (false):
            background.image = UIImage (named: backgroundImagePath)
        }
        
        //assigns values to detail view items
        tableCompany.text = companyName
        yearWorked.text = yearOfWork
        logo.image = UIImage (named: imageString)
        details.text = myInfo.jobDescription [indexPath]
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) { //rotation handling
        
        switch (UIDevice.current.orientation.isLandscape){
        case (true):
            background.isHidden = true
            yConstraintLogo.constant = -20
        case (false):
            background.isHidden = false
            yConstraintLogo.constant = 0
        }
    }
}
