//
//  FileManager+IFileManager.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 05.04.2022.
//

import Foundation

extension FileManager: IFileManager {
	
	func scan(path: String, for fileExtension: String) -> [URL] {
		guard let enumerator = enumerator(
			at: URL(fileURLWithPath: path),
			includingPropertiesForKeys: [.isRegularFileKey],
			options: [.skipsHiddenFiles, .skipsPackageDescendants]
		) else { return [] }
		var files: [URL] = []
		for case let fileURL as URL in enumerator {
			do {
				let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
				guard fileAttributes.isRegularFile ?? false, fileURL.pathExtension == fileExtension else { continue }
				files.append(fileURL)
			} catch {
				print(error, fileURL)
			}
		}
		return files
	}
	
	func save(_ sourceFile: SourceFile) {
		let filePath = sourceFile.path.replacingOccurrences(of: ".swift", with: ".mcd")
		if !createFile(atPath: filePath, contents: sourceFile.mermaidDescription.data(using: .utf8)) {
			print("File not created")
		}
	}
}
