//
//  Extensions.swift
//  
//
//  Created by Kamaal Farah on 08/11/2020.
//

import Foundation

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
