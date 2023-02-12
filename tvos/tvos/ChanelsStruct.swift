//
//  ChanelsStruct.swift
//  tvos
//
//  Created by Артем Пашевич on 12.02.23.
//

import Foundation

struct PackageResponse: Decodable {
    let data: PackageData
}

struct PackageData: Decodable {
    let packages: [Package]
    let playlists: [Playlist]
}

struct Package: Decodable {
    let id: String
    let name: String
    let streams: [Stream]
    let vods: [Vod]
    let episodes: [Episode]
    let seasons: [Season]
    let serials: [Serial]
    let description: String
    let backgroundURL: String
    let available: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case streams
        case vods
        case episodes
        case seasons
        case serials
        case description
        case backgroundURL = "background_url"
        case available
    }
}

struct Stream: Decodable {
    let id: String
    let groups: [Group]
    let iarc: Int
    let parts: [Part]
    let viewCount: Int
    let meta: [Meta]
    let createdDate: Int
    let video: Bool
    let audio: Bool
    let price: Int
    let pid: String
    let favorite: Bool
    let locked: Bool
    let recent: Int
    let interruptTime: Int
    let epg: EPG
    let archive: Bool
    
    private enum CodingKeys: String, CodingKey {
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

struct EPG: Decodable {
    let id: String
    let urls: [String]
    let displayName: String
    let icon: String
    let programs: [Program]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case urls
        case displayName = "display_name"
        case icon
        case programs
    }
}

// Other structs like Playlist, Vod, Episode, Season, Serial, Group, Part, and Meta can be defined in a similar way
