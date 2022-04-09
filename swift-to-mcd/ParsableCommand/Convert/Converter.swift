//
//  Converter.swift
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

final class Converter {
	
	// Dependencies
	private let fileManager: IFileManager
	private let sourceFileParser: SourceFileParser
	
	// MARK: - Initialization
	
	init(fileManager: IFileManager,
		 sourceFileParser: SourceFileParser) {
		self.fileManager = fileManager
		self.sourceFileParser = sourceFileParser
	}
	
	// MARK: - Public
	
	func start() {
		let startTime = Date()
		let targetPath = fileManager.currentDirectoryPath
		print("Looking for Swift files at:", targetPath)
		let urls = fileManager.scan(path: targetPath, for: "swift")
		print("Processing files")
		var files: [SourceFile] = []
		sourceFileParser.parseFiles(on: urls) { file in
			files.append(file)
		}
		fileManager.save(files, at: targetPath)
		print("DONE")
		print("Time:", Int(startTime.timeIntervalSinceNow * -1000), "ms")
	}
}
