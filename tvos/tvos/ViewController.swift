//
//  ViewController.swift
//  tvos
//
//  Created by Артем Пашевич on 12.02.23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    
    @IBAction func next(_ sender: Any) {
        SocketManager.shared.loginWithPassword(email: "test@crocott.com", password: "1111", device: Settings.getID())
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        SocketManager.shared.postClientLogin(login: "test@crocott.com", password: "1111") { result, error in
//            print("access " + result.access_token)
//            print("refresh " + result.refresh_token)
//
//            SocketManager.shared.clientGetContent { cont in
//                print(cont as Any)
//            }
//
//            SocketManager.shared.clientGetProfile { Info in
//                print(Info as Any)
//            }
//
//        }
//
//        SocketManager.shared.getDevices(login: "test@crocott.com", password: "1111") { result, error in
//            print(result)
//        }
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }

        
    
//        SocketManager.shared.getDevices(login: "test@crocott.com", password: "1111") { result, error in
//            print(Settings.getID())
//            print(Settings.getRefreshToken())
//            print(Settings.getAccessToken())
//            SocketManager.shared.devices = result
//            for device in SocketManager.shared.devices {
//                if (device.name == SocketManager.shared.getDevice()) {
//                    print(device)
//
//                }
//            }
//            SocketManager.shared.LOGIN(accessToken: Settings.getAccessToken(), refreshToken: Settings.getRefreshToken(), login: "test@crocott.com", password: "1111", id: Settings.getID()) { result in
//                print(result)
//            }
                
            
            
//        }
        
//        SocketManager.shared.loginWithPassword(email: email.text!, password: password.text!, device: Settings.getID())
//        
//        SocketManager.shared.clientGetProfile { json in
//            print(json)
//        }
        
        
        
    }

}

