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
                                         content: Content) throws -> Bool {
        try _createFile(fileName: fileName, fileExtension: fileExtension, content: content, force: true)
    }

    func removeFile(fileName: String, fileExtension: String? = nil) throws -> Bool {
        guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
            throw CloudDocsError.cloudDocumentFolderNotFound
        }
        let fileURL = cloudDocumentContainerUrl.appendFile(name: fileName, fileExtension: fileExtension)
        let fileExistsInDirectory = try _checkIfFileExists(in: cloudDocumentContainerUrl, fileURL: fileURL)
        guard fileExistsInDirectory else { throw CloudDocsError.fileNotFound }
        try fileManager.removeItem(at: fileURL)
        return true
    }

    func readFile<File: Decodable>(fileName: String, fileExtension: String? = nil) throws -> File {
        guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
            throw CloudDocsError.cloudDocumentFolderNotFound
        }
        let fileURL = cloudDocumentContainerUrl.appendFile(name: fileName, fileExtension: fileExtension)
        let fileExistsInDirectory = try _checkIfFileExists(in: cloudDocumentContainerUrl, fileURL: fileURL)
        guard fileExistsInDirectory else { throw CloudDocsError.fileNotFound }
        let data = try Data(contentsOf: URL(fileURLWithPath: fileURL.path), options: .mappedIfSafe)
        let jsonResult = try JSONDecoder().decode(File.self, from: data)
        return jsonResult
    }

    func createFile<Content: Encodable>(fileName: String,
                                        fileExtension: String? = nil,
                                        content: Content) throws -> Bool {
        try _createFile(fileName: fileName, fileExtension: fileExtension, content: content, force: false)
    }

    func checkIfFileExists(fileName: String, fileExtension: String? = nil) throws -> Bool {
        guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
            throw CloudDocsError.cloudDocumentFolderNotFound
        }
        let fileURL = cloudDocumentContainerUrl.appendFile(name: fileName, fileExtension: fileExtension)
        return try _checkIfFileExists(in: cloudDocumentContainerUrl, fileURL: fileURL)
    }

    func listAllFileURLs() throws -> [URL] {
        guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
            throw CloudDocsError.cloudDocumentFolderNotFound
        }
        return try _listAllFileURLs(from: cloudDocumentContainerUrl)
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
    func createFolderIfNotExists(from url: URL) throws -> CreateFolder {
        guard !fileManager.fileExists(atPath: url.path, isDirectory: nil) else { return .exists }
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return .created
    }

    func _listAllFileURLs(from url: URL) throws -> [URL] {
        let folder = try createFolderIfNotExists(from: url)
        switch folder {
        case .created, .exists:
            let urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            return urls
        }
    }

    func _checkIfFileExists(in directory: URL, fileURL: URL, fileExtension: String? = nil) throws -> Bool {
        let urls = try _listAllFileURLs(from: directory)
        return urls.contains(fileURL)
    }

    func _createFile<Content: Encodable>(fileName: String,
                                        fileExtension: String?,
                                        content: Content,
                                        force: Bool) throws -> Bool {
        guard let cloudDocumentContainerUrl = fileManager.cloudDocumentContainerUrl else {
            throw CloudDocsError.cloudDocumentFolderNotFound
        }
        let fileURL = cloudDocumentContainerUrl.appendFile(name: fileName, fileExtension: fileExtension)
        let fileExistsInDirectory = try _checkIfFileExists(in: cloudDocumentContainerUrl, fileURL: fileURL)
        guard !fileExistsInDirectory || force else { throw CloudDocsError.fileAllreadyExists }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encodedContent = try encoder.encode(content)
        let created = fileManager.createFile(atPath: fileURL.path,
                                             contents: encodedContent, attributes: nil)
        return created
    }
}

internal enum CreateFolder {
    case exists
    case created
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
