

import UIKit
//All things related to the Particle_SDK will be inspired by examples from the documentation.
import Particle_SDK
class ViewController: UIViewController {
    
    

    @IBOutlet weak var toggleAlarm: UISwitch!
    @IBOutlet weak var doorLastOpened: UILabel!
    @IBOutlet weak var tempVal: UILabel!
    var myDevices = [ParticleDevice]()
    var pickerData: [String] = [String]()
    var myDevice: ParticleDevice!
    var deviceId: String!
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToDoorEvent()
        subscribeToTemp()
        print(myDevices)
        var myPhoton : ParticleDevice?
        
    }
    //Function that calls the "setOfAlarm()" function of the device
    @IBAction func toggleAlarm(_ sender: UISwitch) {
        for device in myDevices {
            if(device.id == deviceId) {
                myDevice = device
            }
        }
        print("devices\(myDevice)")
        if (sender.isOn) {
            myDevice.callFunction("setOfAlarm", withArguments: ["on"])
        } else {
            myDevice.callFunction("setOfAlarm", withArguments: ["off"])
        }
    }
    
    /*Function that subscribes to the "doorOpen" event. The time when the door was opened will be live updated in the app. The time is also correctly formatted before it is displayed.
     This will be inspired by: https://docs.particle.io/reference/SDKs/ios/#events-sub-system*/
    func subscribeToDoorEvent() {
        ParticleCloud.sharedInstance().subscribeToMyDevicesEvents(withPrefix: "doorOpen", handler: { (event: ParticleEvent?, error: Error? ) in
            if let _ = error {
                print("subscribe failed \(error)")
            } else {
                
                DispatchQueue.main.async(execute: {
                    print(event?.data)
                    var dateFormatter = DateFormatter()
                    print(event?.time)
                    let currentDateTime = Date()
                    let dateText = dateFormatter.string(from: currentDateTime)
                    let calendar = Calendar.current
                    let month = calendar.component(.month, from: event!.time)
                    let day = calendar.component(.day, from: event!.time)
                    let hour = calendar.component(.hour, from: event!.time)
                    let minutes = calendar.component(.minute, from: event!.time)
                    self.doorLastOpened.text = String(format: "%02d:%02d, %02d.%02d", hour, minutes, month, day)
                })
            }
        })
    }
    /*Function that subscribes to the "currentTemp" event. If the temperature changes, this is live updated in the application.
     This will be inspired by: https://docs.particle.io/reference/SDKs/ios/#events-sub-system*/
    func subscribeToTemp() {
    ParticleCloud.sharedInstance().subscribeToMyDevicesEvents(withPrefix: "currentTemp", handler: { (event :ParticleEvent?, error : Error?) in
            if let _ = error {
                print ("could not subscribe to events")
            } else {
                self.deviceId = event?.deviceID
                DispatchQueue.main.sync(execute: {
                    
                    print("temp: \(String(describing: event?.data))")
                    var currentTemp = event?.data
                    self.tempVal.text = "\(String(currentTemp!))°C"
                })
            }
        })
    }
}

