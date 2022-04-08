//
//  IFileManager.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 05.04.2022.
//

import Foundation

protocol IFileManager {
	var currentDirectoryPath: String { get }
	func scan(path: String, for fileExtension: String) -> [URL]
	func save(_ sourceFile: SourceFile)
}
