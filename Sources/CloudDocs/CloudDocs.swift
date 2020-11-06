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
        DispatchQueue.global().async { [self] in
            guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
                completion(false, CloudDocsError.cloudDocumentFolderNotFound)
                return
            }
            do {
                let urls = try fileManager.contentsOfDirectory(at: cloudDocumentContainerUrl,
                                                               includingPropertiesForKeys: nil,
                                                               options: [])
                let fileURL = cloudDocumentContainerUrl.appendFile(name: fileName, fileExtension: fileExtension)
                if urls.contains(fileURL) {
                    try fileManager.removeItem(at: fileURL)
                    completion(true, nil)
                } else {
                    completion(false, CloudDocsError.fileNotFound)
                    return
                }
            } catch {
                completion(false, error)
            }
        }
    }

    func readFile<File: Decodable>(fileName: String,
                                   fileExtension: String? = nil,
                                   completion: @escaping (_ file: File?, _ error: Error?) -> Void) {
        DispatchQueue.global().async { [self] in
            guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
                completion(nil, CloudDocsError.cloudDocumentFolderNotFound)
                return
            }
            do {
                let urls = try fileManager.contentsOfDirectory(at: cloudDocumentContainerUrl,
                                                               includingPropertiesForKeys: nil,
                                                               options: [])
                let fileURL = cloudDocumentContainerUrl.appendFile(name: fileName, fileExtension: fileExtension)
                if urls.contains(fileURL) {
                    let data = try Data(contentsOf: URL(fileURLWithPath: fileURL.path), options: .mappedIfSafe)
                    let jsonResult = try JSONDecoder().decode(File.self, from: data)
                    completion(jsonResult, nil)
                    return
                } else {
                    completion(nil, CloudDocsError.fileNotFound)
                    return
                }
            } catch {
                completion(nil, error)
                return
            }
        }
    }

    func createFile<Content: Encodable>(fileName: String,
                                        fileExtension: String? = nil,
                                        content: Content,
                                        force: Bool = false,
                                        completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        DispatchQueue.global().async { [self] in
            guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
                completion(false, CloudDocsError.cloudDocumentFolderNotFound)
                return
            }
            createFolderIfNotExists(from: cloudDocumentContainerUrl) { (error: Error?) in
                if let error = error {
                    completion(false, error)
                    return
                }
                do {
                    let urls = try fileManager.contentsOfDirectory(at: cloudDocumentContainerUrl,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: [])
                    let fileURL = cloudDocumentContainerUrl.appendFile(name: fileName, fileExtension: fileExtension)
                    if !urls.contains(fileURL) || force {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let encodedContent = try encoder.encode(content)
                        let created = fileManager.createFile(atPath: fileURL.path,
                                                             contents: encodedContent, attributes: nil)
                        completion(created, nil)
                    } else {
                        completion(false, CloudDocsError.fileAllreadyExists)
                    }
                } catch {
                    completion(false, error)
                }
            }
        }
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
        }
    }
}

internal extension CloudDocs {
    func createFolderIfNotExists(from url: URL, completion: @escaping (_ error: Error?) -> Void) {
        if fileManager.fileExists(atPath: url.path, isDirectory: nil) {
            completion(nil)
        } else {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                completion(nil)
            } catch {
                completion(error)
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
