//
//  Converter.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 27.03.2022.
//

import Foundation

final class Converter {
	
	// Dependencies
	private let fileManager: IFileManager
	private let sourceFileParser: SourceFileParser
	
	// MARK: - Initialization
	
	init(fileManager: FileManager,
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
		sourceFileParser.parseFiles(on: urls) { file in
			fileManager.save(file)
		}
		print("DONE")
		print("Time:", Int(startTime.timeIntervalSinceNow * -1000), "ms")
	}
}
