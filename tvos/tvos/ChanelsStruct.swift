//
//  ChanelsStruct.swift
//  tvos
//
//  Created by Артем Пашевич on 12.02.23.
//

import Foundation

struct Package: Decodable {
    let id: String
    let name: String
    let streams: [Stream]
    let vods: [String]
    let episodes: [String]
    let seasons: [String]
    let serials: [String]
    let description: String
    let backgroundUrl: String
    let available: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case streams
        case vods
        case episodes
        case seasons
        case serials
        case description
        case backgroundUrl = "background_url"
        case available
    }
}

struct Stream: Decodable {
    let id: String
    let groups: [String]
    let iarc: Int
    let parts: [String]
    let viewCount: Int
    let meta: [String]
    let createdDate: Int
    let video: Bool
    let audio: Bool
    let price: Int
    let pid: String
    let favorite: Bool
    let locked: Bool
    let recent: Int
    let interruptTime: Int
    let epg: Epg
    let archive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case groups
        case iarc
        case parts
        case viewCount = "view_count"
        case meta
        case createdDate = "created_date"
        case video
        case audio
        case price
        case pid
        case favorite
        case locked
        case recent
        case interruptTime = "interrupt_time"
        case epg
        case archive
    }
}

struct Epg: Decodable {
    let id: String
    let urls: [String]
    let displayName: String
    let icon: String
    let programs: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case urls
        case displayName = "display_name"
        case icon
        case programs
    }
}

struct Data1: Decodable {
    let packages: [Package]
    let playlists: [String]
}

struct JSONData: Decodable {
    let data: Data1
}

