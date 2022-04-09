//
//  Generate.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 09.04.2022.
//

import Foundation
import ArgumentParser

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
		let targetFileUrl = url.appendingPathComponent("result.mcd")
		let resultUrl = url.appendingPathComponent("classDiagram.pdf")
		
		task.standardOutput = pipe
		task.standardError = pipe
		task.arguments = ["-c", "mmdc -i \(targetFileUrl.path) -o \(resultUrl.path) -t dark"]
		task.executableURL = URL(fileURLWithPath: "/bin/zsh")
		
		try task.run()
		
		print("Generated file saved as:", resultUrl.path)
	}
}
