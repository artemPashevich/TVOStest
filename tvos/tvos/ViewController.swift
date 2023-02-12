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
        
        SocketManager.shared.postClientLogin(login: "test@crocott.com", password: "1111") { result, error in
            print("access" + result.access_token)
            print("refresh" + result.refresh_token)
            
            SocketManager.shared.updateAccessToken(login: "test@crocott.com", password: "1111", refresh_token: SocketManager.shared._tokens!.refresh_token) { token in
                print(token?.refresh_token as Any)
                print(token?.access_token as Any)
            }
        }
    }

}

