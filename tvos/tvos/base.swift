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

class AppState {
    init() {}
}

class UnAuthenticateAppState: AppState {
    override init() {
        super.init()
    }
}

class LoadingAppState: AppState {
    let text: String
    
    init(text: String) {
        self.text = text
        super.init()
    }
}

class ErrorAppState: AppState {
    let error: Error
    
    init(error: Error) {
        self.error = error
        super.init()
    }
}

class AuthenticatedAppState: AppState {
    let server: String
    let device: String
    let info: Data2
    
    init(server: String, device: String, info: Data2) {
        self.server = server
        self.device = device
        self.info = info
        super.init()
    }
}


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
        setTokens(tokens: tokens)
    }
    
    func getDevice() -> String? {
        return UIDevice.current.name
    }
    
    
//    func signUp(accessToken: String?, refreshToken: String?, device: String?) {
//        if (accessToken != nil && refreshToken != nil && device != nil) {
//            let tokens = Tokens(refresh_token: refreshToken!, access_token: accessToken!)
//            setTokens(tokens: tokens)
//            // next get server info !!!!!
//        }
//
//    }
    
    
    
//    func generateJsonHeadersWithCode(code: String) -> [String: String] {
//        return [
//            "content-type": "application/json",
//            "accept": "application/json",
//            "Authorization": "Code \(code)"
//        ]
//    }

    func showLoadingIndicator(withText text: String) {
        // Создаем UIActivityIndicatorView
        let viewController = ViewController()
        let rootView = viewController.view
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        guard let view = rootView else { return }
        // Добавляем UIActivityIndicatorView на view
        view.addSubview(activityIndicator)
        
        // Создаем UILabel
        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        // Добавляем UILabel на view
        view.addSubview(label)
        
        // Добавляем constraints для UIActivityIndicatorView и UILabel
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16)
        ])
    }
    
    func loginWithPassword(email: String, password: String, device: String?) {
        guard !email.isEmpty, !password.isEmpty else {
//            _emit(ErrorAppState(error: ErrorHttp(statusCode: 401, message: "TR_ERR_WRONG_LOG_PAS", data: nil)))
            return
        }
        
        showLoadingIndicator(withText: "TR_CONNECTING")
        
        var selectedDevice = device
        
        if selectedDevice == nil {
            showLoadingIndicator(withText: "TR_REQUEST_DEVICES")
            var devices = [DeviceInfo]()
            getDevices(login: email, password: password) { device, error in
                devices = device
                if !devices.isEmpty {
                    selectedDevice = devices[0].id
                }
                if devices.isEmpty {
                    self.showLoadingIndicator(withText: "TR_REQUEST_NEW_DEVICE")
                    self.requestDevice(login: email, password: password) { device in
                        devices.append(device!)
                    }
                }
            }
            
            
        }
        
        if selectedDevice == nil {
//            _emit(ErrorAppState(error: ErrorHttp(statusCode: 401, message: "TR_PLEASE_CREATE_DEVICE", data: nil)))
            return
        }
        
        showLoadingIndicator(withText: "TR_AUTHORIZATION")
        
        login(login: email, password: password, deviceId: selectedDevice!) { token, error in
            self.setTokens(tokens: token)
        }
//            _emit(ErrorAppState(error: ErrorHttp(statusCode: 401, message: "TR_ERR_WRONG_LOG_PAS", data: nil)))
           
            
//        guard let info = getServerInfo() else { return } //_emit(ErrorAppState(error: error)) }
//        AuthenticatedAppState(server: SocketManager.getBackendEndpoint, device: selectedDevice!, info: info)
    }

    
    func generateJsonHeaders(login: String, password: String) -> [String: String] {
        let encodedData = Data("\(login):\(password)".utf8).base64EncodedString()
        return [
            "content-type": "application/json",
            "accept": "application/json",
            "authorization": "Basic \(encodedData)"
        ]
    }
    
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



    
    func login(login: String, password: String, deviceId: String, callback: @escaping (_ result: Tokens, _ error: Error?) -> Void) {
        
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
    
        
    func requestDevice(login: String, password: String, completion: @escaping (DeviceInfo?) -> Void) {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/client/devices/add")
        let headers = generateJsonHeaders(login: login, password: password)
        let parameters: Dictionary = ["name": getDevice()]
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
    
    
    func updateAccessToken(login: String, password: String, refresh_token: String) -> Tokens? {
            
            let url = URL(string: SocketManager.getBackendEndpoint + "/client/refresh_token")
            let headers = generateJsonHeaders(login: login, password: password)
            let body = ["refresh_token": refresh_token]
            
            let semaphore = DispatchSemaphore(value: 0)
            var result: Tokens?
            
            AF.request(url!, method: .post, parameters: body as Parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(headers))
                .responseData { response in
                    defer {
                        semaphore.signal()
                    }
                    switch response.result {
                    case .success(let data):

                        do {
                            let decodeTokens = try JSONDecoder().decode(DataTokens.self, from: data)
                            result = decodeTokens.data
                            self._setTokens(tokens: result!)
                            
                        } catch {
                            print(error)
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            
            _ = semaphore.wait(timeout: .distantFuture)
            return result
        }

    
    
    func clientGetContent() -> JSON? {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/client/content")
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: JSON?
        
        AF.request(url!, method: .get, headers: HTTPHeaders(_getHeaders()))
            .responseData { response in
                defer {
                    semaphore.signal()
                }
                switch response.result {
                case .success(let data):

                    do {
                        let json = try JSON(data: data)
                        result = json
                    } catch {
                        print(error)
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return result
    }
    
    
    func clientGetProfile() -> JSON? {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/client/profile")
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: JSON?
        
        AF.request(url!, method: .get, headers: HTTPHeaders(_getHeaders()))
            .responseData { response in
                defer {
                    semaphore.signal()
                }
                switch response.result {
                case .success(let data):

                    do {
                        let json = try JSON(data: data)
//                        let decodeContent = try JSONDecoder().decode(JSON.self, from: data)
                        result = json
                    } catch {
                        print(error)
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return result
    }
    
    
    func getServerInfo(completion: @escaping (Data2?) -> Void) {
        
        let url = URL(string: SocketManager.getBackendEndpoint + "/info")
        
        AF.request(url!, method: .get)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    
                    do {
                        let json = try JSON(data: data)
                        let decodeServer = try JSONDecoder().decode(Response.self, from: data)
                        completion(decodeServer.data)
                    } catch {
                        print(error)
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    
    
    func _getHeaders() -> [String: String] {
        var headers: [String: String] = [:]
            headers["Authorization"] = "Bearer \(Settings.getAccessToken())"
        
        return headers
    }
    
    
    
}
