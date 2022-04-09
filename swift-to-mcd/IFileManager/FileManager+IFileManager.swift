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
	
	func save(_ sourceFiles: [SourceFile], at path: String) {
		let filePath = path.appending("/result.mcd")
		let result = sourceFiles.reduce("classDiagram\n\n") { partialResult, file in
			partialResult.appending(file.mermaidDescription)
		}
		if !createFile(atPath: filePath, contents: result.data(using: .utf8)) {
			print("File not created")
		}
	}
}
