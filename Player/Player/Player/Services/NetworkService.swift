//
//  NetworkService.swift
//  Player
//
//  Created by Ситора Гулямова on 29.12.17.
//  Copyright © 2017 Sitora. All rights reserved.
//

import Foundation

private enum PossibleURLs: String {
    case basicSearcURL = "https://itunes.apple.com/search?term="
}

final class NetworkService {
    private let session = URLSession.shared
    
    func request() {
        
    }
}
extension NetworkService {
    func songsWithLimitURL(name: String, limit: Int) -> URL? {
        return URL(string: PossibleURLs.basicSearcURL.rawValue + "\(name)&entity=song&limit=\(limit)")
    }
}
