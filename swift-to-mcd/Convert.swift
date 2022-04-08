//
//  Convert.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 27.03.2022.
//

import Foundation
import ArgumentParser

struct Convert: ParsableCommand {
	
	static var configuration: CommandConfiguration {
		.init(
			commandName: "convert",
			abstract: "Convert *.swift files to *.mcd"
		)
	}
	
	func run() throws {
		let converter = Converter(
			fileManager: FileManager.default,
			sourceFileParser: SwiftSourceFileParser()
		)
		converter.start()
	}
}
