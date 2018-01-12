import Foundation

final class NetworkService {
    private let session = URLSession.shared

    func downloadAudioRequest(url: URL, songId: Int64, completionHandler: @escaping (_ result: URL?) -> Void) {
        guard let localURL = StorageService.sharedInstance.documentsURL() else {
            return completionHandler(nil)
        }
        let destinationUrl = localURL.appendingPathComponent("\(songId)" + ".m4a")

        URLSession.shared.downloadTask(with: url, completionHandler: { location, response, error -> Void in
            guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("audio"),
                    let location = location, error == nil
                    else {
                return completionHandler(nil)
            }

            try? FileManager.default.moveItem(at: location, to: destinationUrl)
            return completionHandler(destinationUrl)
        }).resume()
    }

    func downloadDataRequest(url: URL, completionHandler: @escaping (_ result: Data?) -> Void) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, _, error) in
            guard error == nil,
                  let usableData = data else {
                return completionHandler(nil)
            }
            completionHandler(usableData)
        }
        task.resume()
    }
}
