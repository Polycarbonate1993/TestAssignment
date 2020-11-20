//
//  Model.swift
//  TestAssignment
//
//  Created by Андрей Гедзюра on 19.11.2020.
//

import Foundation

/// Wrapper for the whole rsponse from the server.
class SearchResult: Codable {
    /**Number of items in search result.*/
    let resultCount: Int
    /**The array of Albums in response.*/
    let results: [Result]
    
    private enum CodingKeys: String, CodingKey {
        case resultCount
        case results
    }
}

/// Wrapper for JSON representation of album entity.
class Result: Codable, Hashable {
    /**The ID of the album*/
    let collectionId: Int
    /**The name of the album's artist*/
    let artistName: String
    /**The name of the album.*/
    let collectionName: String
    /**String URL for artwork in 60x60 resolution.*/
    let artworkSmall: String?
    /**String URL for artwork in 100x100 resolution.*/
    let artworkBig: String?
    /**The number of songs in the album*/
    let trackCount: Int
    /**Copyright information*/
    let copyright: String?
    /**The release date of the album in "yyyy-MM-dd'T'HH:mm:ssZZZZZ" format*/
    let releaseDate: String
    
    static func == (lhs: Result, rhs: Result) -> Bool {
        return lhs.collectionId == rhs.collectionId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(collectionId)
    }
    
    private enum CodingKeys: String, CodingKey {
        case collectionId
        case artistName
        case collectionName
        case artworkSmall = "artworkUrl60"
        case artworkBig = "artworkUrl100"
        case trackCount
        case copyright
        case releaseDate
    }
}
