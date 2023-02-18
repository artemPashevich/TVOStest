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
    
    var devices: [DeviceInfo] = []
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
    
    func _info(id: String) -> SystemInfo {
        let os = OS(name: UIDevice.current.name, version: UIDevice.current.systemVersion, arch: UIDevice.current.model, ram_total: 0, ram_free: 0)
        let project = Project(name: UIDevice.current.name, version: "1.0.0.1") // version ??
        let systemInfo = SystemInfo(id: id, project: project, os: os, cpu_brand: "TV OS")
        return systemInfo
    }
    
    func saveToken(tokens: Tokens) {
        Settings.setAccessToken(token: tokens)
        Settings.setRefreshToken(token: tokens)
    }
    
    func getDevice() -> String? {
        return UIDevice.current.name
    }
    
    func getId() -> String {
        var id = ""
        for device in devices {
            if (device.name == getDevice()) {
                id = device.id
            }
        }
        return id
    }
    
//    func signUp(accessToken: String?, refreshToken: String?, device: String?) {
//        if (accessToken != nil && refreshToken != nil && device != nil) {
//            let tokens = Tokens(refresh_token: refreshToken!, access_token: accessToken!)
//            setTokens(tokens: tokens)
//            // next get server info !!!!!
//        }
//
//    }
    
    func LOGIN(accessToken: String, refreshToken: String, login: String, password: String, device: String) -> Bool {
        if(accessToken == "" && refreshToken == "") {
            
            if(device == "") {
                
                addDevice(login: login, password: password) { device in
                    self.devices.append(device!)
                    Settings.setDevice()
                }
                
                postClientLogin(login: login, password: password, deviceId: getId()) { result, error in
                    self.saveToken(tokens: result)
                }
                return true
            } else {
                postClientLogin(login: login, password: password, deviceId: getId()) { result, error in
                    self.saveToken(tokens: result)
                }
                return true
            }
            
        } else {
            return true
        }
    }
    
    
    
    
//    func generateJsonHeadersWithCode(code: String) -> [String: String] {
//        return [
//            "content-type": "application/json",
//            "accept": "application/json",
//            "Authorization": "Code \(code)"
//        ]
//    }

    
    func getDevices(login: String, password: String, callback: @escaping (_ result: [DeviceInfo], _ error: Error?) -> Void) {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/client/devices")
        
        AF.request(url!, method: .get, encoding: JSONEncoding.default, headers: HTTPHeaders(self.generateJsonHeaders(login: login, password: password)))
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        
                        do {
                            let devicesJson = try JSONDecoder().decode(GetDataJson.self, from: data)
                            let devices = devicesJson.data.devices
                            callback(devices, nil)
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
    
    func generateJsonHeaders(login: String, password: String) -> [String: String] {
        let encodedData = Data("\(login):\(password)".utf8).base64EncodedString()
        return [
            "content-type": "application/json",
            "accept": "application/json",
            "authorization": "Basic \(encodedData)"
        ]
    }
    
    
    func postClientLogin(login: String, password: String, deviceId: String, callback: @escaping (_ result: Tokens, _ error: Error?) -> Void) {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/client/login")
        
            let encodeBody = self._info(id: deviceId)
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
    
        
    func addDevice(login: String, password: String, completion: @escaping (DeviceInfo?) -> Void) {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/client/devices/add")
        let headers = generateJsonHeaders(login: login, password: password)
        let parameters: Dictionary = ["name": getDevice()]
        Settings.setDevice()
        AF.request(url!, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(headers))
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
                        print(json)
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
    
    func clientGetProfile(completion: @escaping (JSON?) -> Void) {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/client/profile")
        AF.request(url!, method: .get, headers: HTTPHeaders(_getHeaders()))
            .responseData { response in
                switch response.result {
                case .success(let data):

                    do {
                        let json = try JSON(data: data)
//                        let decodeContent = try JSONDecoder().decode(JSON.self, from: data)
                        print(json)
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
    
    
    
}
