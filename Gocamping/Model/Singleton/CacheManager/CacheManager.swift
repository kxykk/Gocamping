//
//  CacheManager.swift
//  Gocamping
//
//  Created by 康 on 2023/9/12.
//

import UIKit

class CacheManager {

    // MARK: - Singleton Instance
    static let shared = CacheManager()

    // MARK: - Save Data
    func save(data: Data, filename: String) throws {
        let finalFilenameURL = urlFor(filename: filename)
        try data.write(to: finalFilenameURL)
    }

    // MARK: - Load Data
    func load(filename: String) -> UIImage? {
        let finalFilenameURL = urlFor(filename: filename)
        return UIImage(contentsOfFile: finalFilenameURL.path)
    }

    // MARK: - Helper Function for URL
    private func urlFor(filename: String) -> URL {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cacheURL.appendingPathComponent(filename)
    }

    // MARK: - Purge Cache
    func purge() {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                do {
                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                    if let modificationDate = fileAttributes[FileAttributeKey.modificationDate] as? Date {
                        let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
                        if modificationDate < oneWeekAgo {
                            try FileManager.default.removeItem(at: fileURL)
                            print("Removed \(fileURL)")
                        }
                    }
                } catch {
                    print("Could not remove file at: \(fileURL)")
                }
            }
        } catch {
            print("Could not list files in directory at: \(cacheURL)")
        }
    }
}
