//
//  CacheManager.swift
//  Gocamping
//
//  Created by 康 on 2023/9/12.
//

import UIKit

class CacheManager {
    static let shared = CacheManager()
    
    func save(data: Data, filename: String) throws {
        let finalFilenameURL = urlFor(filename: filename)
        print("Load from: \(finalFilenameURL)")
        try data.write(to: finalFilenameURL)
    }
    
    func load(filename: String) -> UIImage? {
        let finalFilenameURL = urlFor(filename: filename)
        return UIImage(contentsOfFile: finalFilenameURL.path)
    }
    
    private func urlFor(filename: String) -> URL{
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        print("cacheURL: \(cacheURL)")
        return cacheURL.appendingPathComponent(filename)
    }
    
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
