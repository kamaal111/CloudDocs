//
//  CloudDocs.swift
//
//
//  Created by Kamaal Farah on 05/11/2020.
//

import Foundation

public struct CloudDocs {
    private let fileManager = FileManager.default

    public init() { }

    public enum CloudDocsError: Error {
        case fileAllreadyExists
        case fileNotFound
        case cloudDocumentFolderNotFound
        case urlsNotFound
    }
}

public extension CloudDocs {
    func replaceFile<Content: Encodable>(fileName: String,
                                         fileExtension: String? = nil,
                                         content: Content,
                                         completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        createFile(fileName: fileName,
                   fileExtension: fileExtension,
                   content: content,
                   force: true,
                   completion: completion)
    }

    func removeFile(fileName: String,
                    fileExtension: String? = nil,
                    completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
            completion(false, CloudDocsError.cloudDocumentFolderNotFound)
            return
        }
        _listAllFileURLs(from: cloudDocumentContainerUrl) { (urls: [URL]?, error: Error?) in
            if let error = error {
                completion(false, error)
                return
            }
            guard let urls = urls else {
                completion(false, CloudDocsError.urlsNotFound)
                return
            }
            let fileURL = cloudDocumentContainerUrl.appendFile(name: fileName, fileExtension: fileExtension)
            if urls.contains(fileURL) {
                do {
                    try fileManager.removeItem(at: fileURL)
                    completion(true, nil)
                    return
                } catch {
                    completion(false, error)
                    return
                }
            } else {
                completion(false, CloudDocsError.fileNotFound)
                return
            }
        }
    }

    func readFile<File: Decodable>(fileName: String,
                                   fileExtension: String? = nil,
                                   completion: @escaping (_ file: File?, _ error: Error?) -> Void) {
        guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
            completion(nil, CloudDocsError.cloudDocumentFolderNotFound)
            return
        }
        _listAllFileURLs(from: cloudDocumentContainerUrl) { (urls: [URL]?, error: Error?) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let urls = urls else {
                completion(nil, CloudDocsError.urlsNotFound)
                return
            }
            let fileURL = cloudDocumentContainerUrl.appendFile(name: fileName, fileExtension: fileExtension)
            if urls.contains(fileURL) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: fileURL.path), options: .mappedIfSafe)
                    let jsonResult = try JSONDecoder().decode(File.self, from: data)
                    completion(jsonResult, nil)
                    return
                } catch {
                    completion(nil, error)
                    return
                }
            } else {
                completion(nil, CloudDocsError.fileNotFound)
                return
            }
        }
    }

    func createFile<Content: Encodable>(fileName: String,
                                        fileExtension: String? = nil,
                                        content: Content,
                                        force: Bool = false,
                                        completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
            completion(false, CloudDocsError.cloudDocumentFolderNotFound)
            return
        }
        _listAllFileURLs(from: cloudDocumentContainerUrl) { (urls: [URL]?, error: Error?) in
            if let error = error {
                completion(false, error)
                return
            }
            guard let urls = urls else {
                completion(false, CloudDocsError.urlsNotFound)
                return
            }
            let fileURL = cloudDocumentContainerUrl.appendFile(name: fileName, fileExtension: fileExtension)
            if !urls.contains(fileURL) || force {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                do {
                    let encodedContent = try encoder.encode(content)
                    let created = fileManager.createFile(atPath: fileURL.path,
                                                         contents: encodedContent, attributes: nil)
                    completion(created, nil)
                    return
                } catch {
                    completion(false, error)
                    return
                }
            } else {
                completion(false, CloudDocsError.fileAllreadyExists)
                return
            }
        }
    }

    func listAllFileURLs(completion: @escaping (_ urls: [URL]?, _ error: Error?) -> Void) {
        guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
            completion(nil, CloudDocsError.cloudDocumentFolderNotFound)
            return
        }
        _listAllFileURLs(from: cloudDocumentContainerUrl, completion: completion)
    }
}

extension CloudDocs.CloudDocsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fileAllreadyExists:
            return NSLocalizedString("File allready exists", comment: "")
        case .fileNotFound:
            return NSLocalizedString("Given file path could not be found", comment: "")
        case .cloudDocumentFolderNotFound:
            return NSLocalizedString("Could not find cloud document folder", comment: "")
        case .urlsNotFound:
            return NSLocalizedString("Could not find urls", comment: "")
        }
    }
}

internal extension CloudDocs {
    func createFolderIfNotExists(from url: URL, completion: @escaping (_ error: Error?) -> Void) {
        if fileManager.fileExists(atPath: url.path, isDirectory: nil) {
            completion(nil)
            return
        }
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            completion(nil)
            return
        } catch {
            completion(error)
            return
        }
    }

    func _listAllFileURLs(from url: URL, completion: @escaping (_ urls: [URL]?, _ error: Error?) -> Void) {
        createFolderIfNotExists(from: url) { (error: Error?) in
            if let error = error {
                completion(nil, error)
                return
            }
            do {
                let urls = try fileManager.contentsOfDirectory(at: url,
                                                               includingPropertiesForKeys: nil,
                                                               options: [])
                completion(urls, nil)
                return
            } catch {
                completion(nil, error)
                return
            }
        }
    }
}

internal extension URL {
    func appendFile(name: String, fileExtension: String? = nil) -> URL {
        let fileUrl = self.appendingPathComponent(name)
        guard let fileExtension = fileExtension else { return fileUrl }
        return fileUrl.appendingPathExtension(fileExtension)
    }
}

internal extension FileManager {
    var cloudDocumentContainerUrl: URL? {
        self.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
}
