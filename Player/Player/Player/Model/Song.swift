import Foundation
final class Song {
    let singer: String
    let name: String
    let primaryGenre: String

    init(singer: String, name: String) {
        self.singer = singer
        self.name = name
    }

    init(json: [String: Any?]) {
        <#statements#>
    }
}
