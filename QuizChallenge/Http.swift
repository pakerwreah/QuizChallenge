//
//  Http.swift
//  QuizChallenge
//
//  Created by Carlos on 11/02/20.
//  Copyright © 2020 ArcTouch. All rights reserved.
//

import Foundation

extension Data {
    var string: String? {
        return String(data: self, encoding: String.Encoding.utf8)
    }
}

class HttpError: LocalizedError {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        return message
    }
}

class Http {

    class func get<T: Decodable>(url: String, model: T.Type) throws -> T {
        let data = try request(url: url)
        let decoder = JSONDecoder()
        let user = try decoder.decode(model, from: data)
        return user
    }

    class func request(url: String) throws -> Data {
        assert(!Thread.isMainThread, "Network on main thread!")

        let request = URLRequest(url: URL(string: url)!, cachePolicy: .reloadIgnoringCacheData)

        let session = URLSession(configuration: .default)

        let semaphore = DispatchSemaphore(value: 0)

        var data: Data?
        var error: Error?

        session.dataTask(with: request) { (_data: Data?, response: URLResponse?, _error: Error?) in
            data = _data
            error = _error
            semaphore.signal()
        }.resume()

        semaphore.wait()

        if let error = error {
            throw HttpError(error.localizedDescription)
        } else if let data = data {
            return data
        } else {
            throw HttpError("Network connection failed. Please try again.")
        }
    }
}

