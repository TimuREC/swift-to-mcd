//
//  FileManager+IFileManager.swift
//  swift-to-mcd
//
//  Copyright 2022 Timur Begishev
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

private extension String {
	static let resultPath = "/result.mcd"
	static let header = "classDiagram\n\n"
}

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
		let filePath = path.appending(String.resultPath)
		let result = sourceFiles.reduce(String.header) { partialResult, file in
			partialResult.appending(file.mermaidDescription)
		}
		if !createFile(atPath: filePath, contents: result.data(using: .utf8)) {
			print("File not created")
		}
	}
}
