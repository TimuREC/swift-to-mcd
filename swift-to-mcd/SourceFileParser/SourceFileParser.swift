//
//  SourceFileParser.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 27.03.2022.
//

import Foundation

protocol SourceFileParser {
	func parseFiles(on urls: [URL], handler: (SourceFile) -> Void)
}
