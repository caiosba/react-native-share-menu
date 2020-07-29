//
//  URL+Extensions.swift
//  RNShareMenu
//
//  Created by Gustavo Parreira on 29/07/2020.
//

import MobileCoreServices

public extension URL {
    func extractMimeType() -> String {
        let fileExtension: CFString = pathExtension as CFString
        guard let extUTI = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            fileExtension,
            nil
            )?.takeUnretainedValue() else { return "" }

        guard let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType)
            else { return "" }

        return mimeUTI.takeUnretainedValue() as String
    }
}
