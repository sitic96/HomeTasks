import Foundation
final class Song: Codable {
    
    enum CodingKeys: String, CodingKey {
        case singer = "artistName"
        case name = "trackName"
        case primaryGenre = "primaryGenreName"
        case previewLink = "trackViewUrl"
        case artwork = "artworkUrl100"
        case album = "collectionName"
    }
    let singer: String
    let name: String
    let primaryGenre: String
    let previewLink: URL
    let artwork: URL
    let album: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        singer = try values.decode(String.self, forKey: .singer)
        primaryGenre = try values.decode(String.self, forKey: .primaryGenre)
        previewLink = try values.decode(URL.self, forKey: .previewLink)
        artwork = try values.decode(URL.self, forKey: .artwork)
        album = try values.decode(String.self, forKey: .album)
    }
}
