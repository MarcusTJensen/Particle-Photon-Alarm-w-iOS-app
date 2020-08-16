
import UIKit
//All things related to the Particle_SDK will be inspired by examples from the documentation.
import Particle_SDK

class LoginController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    /*Function that logs the user into Particle with the email and password wirrten in the input fields. Will also display an alert if the request is unsuccessful
     Will be inspired by: https://docs.particle.io/reference/SDKs/ios/#common-use-cases*/
    @IBAction func loginToParticle(_ sender: Any) {
        ParticleCloud.sharedInstance().login(withUser: username.text!, password: password.text!) { (error:Error?) -> Void in
            if let _ = error {
                print("Wrong credentials or no internet connectivity, please try again")
                let alert = UIAlertController(title: nil, message: "Wrong credentials or no internet connectivity, please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            else {
                print("Logged in")
                self.performSegue(withIdentifier: "showData", sender: self)
            }
        }
    }
    /*Initializes the next ViewController with the devices registered on the logged in user.*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewController
        
        getDevices() { devices in
            vc.myDevices = devices!
            print(vc.myDevices)
        }
    }
    /*Function that retrieves the devices of the user. This will be inspired by: "https://docs.particle.io/reference/SDKs/ios/#common-use-cases"*/
    func getDevices( completion: @escaping ([ParticleDevice]?) -> Void) {
        ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
            if let _ = error {
                print("Check your internet connectivity")
                completion(nil)
            }
            else {
                completion(devices)
            }
        }
    }
}
