//
//  ViewController.swift
//  tvos
//
//  Created by Артем Пашевич on 12.02.23.
//

import UIKit

class ViewController: UIViewController {

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
        
        
        SocketManager.shared.getDevices(login: "test@crocott.com", password: "1111") { result, error in
            SocketManager.shared.devices = result
            for device in SocketManager.shared.devices {
                if (device.name == SocketManager.shared.getDevice()) {
                    Settings.setDevice()
                }
            }
            if ( SocketManager.shared.LOGIN(accessToken: Settings.getAccessToken(), refreshToken: Settings.getRefreshToken(), login: "test@crocott.com", password: "1111", device: Settings.getDevice())  ) {
                print("Good")
            }
        }
        
        
        
        
        
        
        
    }

}

