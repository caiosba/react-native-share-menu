//
//  NSItemProvider+Extensions.swift
//  RNShareMenu
//
//  Created by Gustavo Parreira on 29/07/2020.
//

import MobileCoreServices

public extension NSItemProvider {
    var isText: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeText as String)
    }

    var isURL: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeURL as String) && !isFileURL
    }

    var isFileURL: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeFileURL as String)
    }
}
