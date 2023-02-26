//
//  Settings.swift
//  tvos
//
//  Created by Артем Пашевич on 16.02.23.
//

import Foundation
import UIKit

final class Settings {
    
    static func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: SettingsKeys.refresh_token.rawValue) ?? nil
    }
    
    static func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: SettingsKeys.access_token.rawValue) ?? nil
    }
    
    static func getID() -> String? {
        return UserDefaults.standard.string(forKey: SettingsKeys.ID.rawValue) ?? nil
    }
    
   static func setRefreshToken(token: Tokens) {
        let defaults = UserDefaults.standard
        defaults.set(token.refresh_token, forKey: SettingsKeys.refresh_token.rawValue)
    }
    
   static func setAccessToken(token: Tokens) {
        let defaults = UserDefaults.standard
        defaults.set(token.access_token, forKey: SettingsKeys.access_token.rawValue)
    }
    
    static func setID(id: String) {
         let defaults = UserDefaults.standard
         defaults.set(id, forKey: SettingsKeys.ID.rawValue)
     }
    
    private enum SettingsKeys: String {
        case access_token
        case refresh_token
        case ID
    }
    
}
