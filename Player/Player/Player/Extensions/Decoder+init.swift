//
//  Decoder+init.swift
//  Player
//
//  Created by Sitora on 30.12.17.
//  Copyright © 2017 Sitora. All rights reserved.
//

import Foundation
extension Decodable {
    init(_ any: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: any, options: .prettyPrinted)
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}
