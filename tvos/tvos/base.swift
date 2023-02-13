//
//  base.swift
//  tvos
//
//  Created by Артем Пашевич on 12.02.23.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire


class SocketManager {
    
//    static let _API_VERSION = "/panel_pro/api"
    static let getBackendEndpoint = "https://ott.fastotv.com/panel_pro/api"
    
    var _tokens: Tokens?
    var onNeedHelp: (() -> Void)?
    var onTokenChanged: ((Tokens) -> Void)?
    
    static let shared = SocketManager()
    
    private init(onTokenChanged: ((Tokens) -> Void)? = nil, onNeedHelp: (() -> Void)? = nil) {
        self.onTokenChanged = onTokenChanged
        self.onNeedHelp = onNeedHelp
    }
    
    func setTokens(tokens: Tokens) {
        _tokens = tokens
    }
    
    func getAccessToken() -> String {
        return _tokens!.access_token
    }
    
    func _setTokens(tokens: Tokens) {
        setTokens(tokens: tokens)
        if let onTokenChanged = onTokenChanged {
            onTokenChanged(tokens)
        }
    }
    
    func _info(id: String, name: String) -> SystemInfo {
        let os = OS(name: UIDevice.current.name, version: UIDevice.current.systemVersion, arch: UIDevice.current.model, ram_total: 0, ram_free: 0)
        let project = Project(name: name, version: "1.0.0.1") // version ??
        let systemInfo = SystemInfo(id: id, project: project, os: os, cpu_brand: "TV OS")
        return systemInfo
    }
    
    func generateJsonHeadersWithCode(code: String) -> [String: String] {
        return [
            "content-type": "application/json",
            "accept": "application/json",
            "Authorization": "Code \(code)"
        ]
    }

    func generateJsonHeaders(login: String, password: String) -> [String: String] {
        let encodedData = Data("\(login):\(password)".utf8).base64EncodedString()
        return [
            "content-type": "application/json",
            "accept": "application/json",
            "authorization": "Basic \(encodedData)"
        ]
    }
    
    
    func postClientLogin(login: String, password: String, callback: @escaping (_ result: Tokens, _ error: Error?) -> Void) {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/client/login")
        
        addDevice(login: login, password: password, name: "TV OS") { device in
            
            let encodeBody = self._info(id: "63e544a32a3b9920437dc9d8" , name: "TV OS")
            let data = try? JSONEncoder().encode(encodeBody)
            let parameters = try? (JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any])
            

            AF.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(self.generateJsonHeaders(login: login, password: password)))
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            
                            do {
                                let tokenJson = try JSONDecoder().decode(DataTokens.self, from: data)
                                let token = tokenJson.data
                                self.setTokens(tokens: token)
                                callback(token, nil)
                            } catch {
                                print(error)
    //                            callback(nil, nil)
                            }
                        case .failure(let error):
                            print(error)
                            //
                            break
                        }
                    }
        }
    }
    
    
    
        
    func addDevice(login: String, password: String, name: String, completion: @escaping (DeviceInfo?) -> Void) {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/client/devices/add")
        let headers = generateJsonHeaders(login: login, password: password)
        let parameters: Dictionary = ["name": name]
       
        
        AF.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(headers))
            .responseData { response in
                switch response.result {
                case .success(let data):

                    do {
                        let decodeDevice = try JSONDecoder().decode(DataJson.self, from: data)
                        let device = decodeDevice.data.device
                        let deviceInfo = DeviceInfo.fromJson(json: [DeviceInfo.ID_FIELD: device.id, DeviceInfo.NAME_FIELD: device.name])
                        completion(deviceInfo)
                        
                    } catch {
                        print(error)
                        completion(nil)
                    }
                    
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
                
            }
    }
    
    
    func updateAccessToken(login: String, password: String, refresh_token: String, completion: @escaping (Tokens?) -> Void) {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/client/refresh_token")
        let headers = generateJsonHeaders(login: login, password: password)
        let refresh_token = _tokens?.refresh_token
        if refresh_token == nil {
            // error
        }
        let body = ["refresh_token": refresh_token]
        
        AF.request(url!, method: .post, parameters: body as Parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(headers))
            .responseData { response in
                switch response.result {
                case .success(let data):

                    do {
                        let decodeTokens = try JSONDecoder().decode(DataTokens.self, from: data)
                        print(decodeTokens.data.access_token)
                        self._setTokens(tokens: decodeTokens.data)
                        completion(decodeTokens.data)
                        
                    } catch {
                        print(error)
                        // compl
                    }
                    
                case .failure(let error):
                    print(error)
                   // compl
                }
            }
    }
    
    
    func clientGetContent(completion: @escaping (JSON?) -> Void) {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/client/content")
        AF.request(url!, method: .get, headers: HTTPHeaders(_getHeaders()))
            .responseData { response in
                switch response.result {
                case .success(let data):

                    do {
                        let json = try JSON(data: data)
//                        let decodeContent = try JSONDecoder().decode(JSON.self, from: data)
                        print(data)
                        completion(json)
                        
                    } catch {
                        print(error)
                        // compl
                    }
                    
                case .failure(let error):
                    print(error)
                   // compl
                }
            }
        
    }
    
    
    
    
    
    func _getHeaders() -> [String: String] {
        var headers: [String: String] = [:]
        if let tokens = _tokens {
            headers["Authorization"] = "Bearer \(tokens.access_token)"
        }
        return headers
    }
    
    
    
//    func login(id: String, name: String, login: String, password: String) {
//
//         var allTokens = [String: Any]()
//
//        let encodeBody: Dictionary = _info(did: id, name: name)
//        let url = URL(string: Fetcher.getBackendEndpoint + "/client/login")
//        let headersOld = generateJsonHeaders(login: login, password: password)
//        let parameters = [
//                "id": "63e50a432a3b9920437dc9d5",
//                "project": [
//                    "name": "TV OS",
//                    "version": "1.4.6"
//                ],
//                "os": [
//                    "name": "Volodyz",
//                    "version": "Mozilla",
//                    "arch": "5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61",
//                    "ram_total": 0,
//                    "ram_free": 0
//                ],
//                "cpu_brand": "Netscape"
//            ] as [String : Any]
//
//        AF.request(url!, method: .post, parameters: encodeBody, encoding: JSONEncoding.default, headers: HTTPHeaders(headersOld)).responseData { response in
//            switch response.result {
//            case .success(let data):
//                let utf8Text = String(data: data, encoding: .utf8)
//                print("Response: \(utf8Text)")
//                print("encodeBody: \(encodeBody)")
//                print("Headers: \(headersOld)")
//                print("URL: \(url!)")
//                do {
//                    let tokenJson = try JSONDecoder().decode(DataTokens.self, from: data)
//                    let token = tokenJson.data
//                    allTokens = [Tokens.refreshToken: token.refresh, Tokens.accessToken: token.access]
//                    print(allTokens)
//                } catch {
//                    print(error)
//        //            completion(nil)
//                }
//            case .failure(let error):
//            print(error)
//            break
//            }
//        }
//
//         print(allTokens)
//     }

//    func getLogin() {
//         var allTokens = [String: Any]()
//
//      //  let encodeBody: Dictionary = info(id: id, name: name)
//        let url = URL(string: Fetcher.getBackendEndpoint + "/client/login")
//        let encodeBody: Dictionary = _info(id: "63e50a432a3b9920437dc9d5", name: "TV OS")
//        let headersOld = generateJsonHeaders(login: "test@crocott.com", password: "1111")
//
//        let parameters = [
//            "id": "63e50a432a3b9920437dc9d5",
//            "project": [
//                "name": "test",
//                "version": "1.4.6"
//            ],
//            "os": [
//                "name": "TV OS",
//                "version": "Mozilla",
//                "arch": "5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61",
//                "ram_total": 0,
//                "ram_free": 0
//            ],
//            "cpu_brand": "Netscape"
//        ] as [String : Any]
//
//        AF.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(headersOld)).responseData { response in
//            switch response.result {
//            case .success(let data):
//                let utf8Text = String(data: data, encoding: .utf8)
//                print("Response: \(utf8Text)")
//                print("encodeBody: \(encodeBody)")
//                print("Headers: \(headersOld)")
//                print("URL: \(url!)")
//                do {
//                    let tokenJson = try JSONDecoder().decode(DataTokens.self, from: data)
//                    let token = tokenJson.data
//                    allTokens = [Tokens.refreshToken: token.refresh_token, Tokens.accessToken: token.access_token]
//                    print(allTokens)
//                } catch {
//                    print(error)
//        //            completion(nil)
//                }
//            case .failure(let error):
//            print(error)
//            break
//            }
//        }
//
//         print(allTokens)
//     }

    
//    func httpGet(url: URL, headers: [String: String], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
//        var request = URLRequest(url: url)
//        request.allHTTPHeaderFields = headers
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            completion(data, response, error)
//        }.resume()
//    }

//    let url = URL(string: getBackendEndpoint)!
//
//    let resp: () = httpGet(url: url, headers: generateJsonHeaders(login: login, password: password)) { data, response, error in
//        if let data = data {
//            print("Data: \(String(data: data, encoding: .utf8)!)")
//        }
//
//        if let response = response {
//            print("Response: \(response)")
//        }
//        if let error = error {
//            print("Error: \(error)")
//        }
//    }
    
}
