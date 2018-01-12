import Foundation

final class Song: Codable {
    private enum CodingKeys: String, CodingKey {
        case singer = "artistName"
        case name = "trackName"
        case trackViewUrl = "previewUrl"
        case primaryGenre = "primaryGenreName"
        case artwork = "artworkUrl100"
        case album = "collectionName"
        case id = "trackId"
        case singerID = "artistId"
    }

    let id: Int64
    let singer: String
    let singerID: Int64
    let name: String
    let primaryGenre: String
    let trackViewUrl: URL
    let artwork: URL
    let album: String
    var length: Int?
    private var liked = false
    var isLiked: Bool {
        return liked
    }

    init(singer: String,
         name: String,
         genre: String,
         link: URL,
         artwork: URL,
         album: String,
         songID: Int64,
         singerID: Int64) {
        self.singer = singer
        self.name = name
        self.primaryGenre = genre
        self.trackViewUrl = link
        self.artwork = artwork
        self.album = album
        self.id = songID
        self.singerID = singerID
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        singer = try values.decode(String.self, forKey: .singer)
        primaryGenre = try values.decode(String.self, forKey: .primaryGenre)
        trackViewUrl = try values.decode(URL.self, forKey: .trackViewUrl)
        artwork = try values.decode(URL.self, forKey: .artwork)
        album = try values.decode(String.self, forKey: .album)
        id = try values.decode(Int64.self, forKey: .id)
        singerID = try values.decode(Int64.self, forKey: .singerID)
    }

    func changeLikeState() {
        liked = !liked
    }
}

extension Song: Equatable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id
    }
}
