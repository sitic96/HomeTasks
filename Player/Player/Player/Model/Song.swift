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

    init(singer: String, name: String, genre: String, link: URL, artwork: URL, album: String) {
        self.singer = singer
        self.name = name
        self.primaryGenre = genre
        self.previewLink = link
        self.artwork = artwork
        self.album = album
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        singer = try values.decode(String.self, forKey: .singer)
        primaryGenre = try values.decode(String.self, forKey: .primaryGenre)
        previewLink = try values.decode(URL.self, forKey: .previewLink)
        artwork = try values.decode(URL.self, forKey: .artwork)
        album = try values.decode(String.self, forKey: .album)
    }

    //    https://stackoverflow.com/a/46327303/4453952
    //    init(from data: [String: Any?]) throws {
    //        let jsonData = try JSONSerialization.data(withJSONObject: data)
    //        let decoder = JSONDecoder()
    //        self = try decoder.decode(Song.self, from: jsonData)
    //    }
}
