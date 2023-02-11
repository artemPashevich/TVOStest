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
            print(result.access_token)
            print(result.refresh_token)
        }
    }

}

