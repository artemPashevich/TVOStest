//
//  struct.swift
//  tvos
//
//  Created by Артем Пашевич on 12.02.23.
//

import Foundation

struct Response: Decodable {
    let data: Data2
}

struct Data2: Decodable {
    let providersCount: Int
    let brand: Brand
    let exp: Int
    private enum CodingKeys: String, CodingKey {
        case providersCount = "providers_count"
        case brand, exp
    }
}

struct Brand: Decodable {
    let title: String
    let logo: String
    let landing: String
    let theme: Int
    let mode: Int
    let platforms: [Platform]
}

struct Platform: Decodable {
    let os: String
    let url: String
}


struct DataTokens: Codable {
    let data: Tokens
}

struct Project: Codable {
    let name: String
    let version: String
}

struct OS: Codable {
    let name: String
    let version: String
    let arch: String
    let ram_total: Int
    let ram_free: Int
}

struct SystemInfo: Codable {
    let id: String
    let project: Project
    let os: OS
    let cpu_brand: String
}


struct DeviceInfo: Codable {
    static let ID_FIELD = "id"
    static let NAME_FIELD = "name"

    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    func copy() -> DeviceInfo {
        return DeviceInfo(id: id, name: name)

    }

    static func fromJson(json: [String: Any]) -> DeviceInfo {
        let id = json[ID_FIELD] as! String
        let name = json[NAME_FIELD] as! String
        return DeviceInfo(id: id, name: name)
    }

    func toJson() -> [String: Any] {
        return [DeviceInfo.ID_FIELD: id, DeviceInfo.NAME_FIELD: name]
    }
}

struct DataJson: Codable {
    var data: Device
}

struct Device: Codable {
    var device: DeviceInfo
}

struct GetDataJson: Codable {
    let data: GetDevice
}

struct GetDevice: Codable {
    let devices: [DeviceInfo]
}

struct ErrorJson: Codable {
    let error: ErrorDetail
}

struct ErrorDetail: Codable {
    let code: Int
    let message: String
}


struct Tokens: Codable {
    
    static let accessToken = "access_token"
    static let refreshToken = "refresh_token"
    
    let refresh_token: String
    let access_token: String
    
    init(refresh_token: String, access_token: String) {
        self.refresh_token = refresh_token
        self.access_token = access_token
    }
}


enum Constants: String {
    
    case access_token = "access_token"
    case refresh_token = "refresh_token"
    case fastourl = "https://ott.fastotv.com/panel_pro/api/"
    case fastoURL = "fastotv.com"
    case ivrataURL = "sg1.ivrata.com"
    case checkOn = "check_on"
    case checkOff = "check_off"
    case rememberFlag = "rememberFlag"
    case invalidEmail = "Invalid Email"
    case invalidPassword = "Invalid password"
    case invalidURL = "Invalid URL"
    case invalidPort = "Invalid Port"
    case switchID = "SwitchID"
    case switchIDViewController = "SwitchIDViewController"
    case email = "email"
    case password = "password"
    case passwordWithoutHash = "passwordWithoutHash"
}
