import Foundation

final class StorageService {
    static let sharedInstance = StorageService()
    private let fileName = "songs.json"
    private var savedSongs = Playlist()
    var favoriteSongs: Playlist {
        return savedSongs
    }
    weak var delegate: FavoriteSongsChanged?

    private init() {
        if let songs = read() {
            savedSongs = songs
        }
    }

    private func save() {
        guard let url = documentsURL() else {
            return
        }

        let completeURL = url.appendingPathComponent(fileName)
        guard let data = try? JSONEncoder().encode(savedSongs.toArray()),
              (try? data.write(to: completeURL, options: [])) != nil else {
            return
        }
        delegate?.favoriteSongsChanged(savedSongs)
    }

    func add(_ song: Song) {
        savedSongs.insert(song)
        save()
    }

    func read() -> Playlist? {
        guard let url = documentsURL() else {
            return nil
        }
        let completeURL = url.appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: completeURL, options: [])
            let result = try JSONDecoder().decode([Song].self, from: data)
            savedSongs = Playlist(result)
            return savedSongs
        } catch {
            return nil
        }
    }

    func remove(_ song: Song) {
        savedSongs.remove(song)
        removeResourceFromDisk(song)
        save()
    }

    private func removeResourceFromDisk(_ song: Song) {
        let fileManager = FileManager.default
        guard let documentsUrl = documentsURL() else {
            return
        }
        let audioPath = documentsUrl.appendingPathComponent("\(song.id)" + ".m4a")
        let imagePath = documentsUrl.appendingPathComponent("\(song.id)" + ".jpg")
        try? fileManager.removeItem(at: audioPath)
        try? fileManager.removeItem(at: imagePath)
    }

    func documentsURL() -> URL? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url
    }
}
