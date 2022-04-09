//
//  Generate.swift
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
import ArgumentParser

private extension String {
	static let resultName = "result.mcd"
	static let diagramName = "classDiagram.pdf"
}

struct Generate: ParsableCommand {
	
	static var configuration: CommandConfiguration {
		.init(
			commandName: "generate",
			abstract: "Generates diagram.pdf from result.mcd"
		)
	}
	
	func run() throws {
		let task = Process()
		guard let url = task.currentDirectoryURL else { return }
		let pipe = Pipe()
		let targetFileUrl = url.appendingPathComponent(.resultName)
		let resultUrl = url.appendingPathComponent(.diagramName)
		
		task.standardOutput = pipe
		task.standardError = pipe
		task.arguments = ["-c", "mmdc -i \(targetFileUrl.path) -o \(resultUrl.path) -t dark"]
		task.executableURL = URL(fileURLWithPath: "/bin/zsh")
		
		try task.run()
		
		print("Generated file saved as:", resultUrl.path)
	}
}
