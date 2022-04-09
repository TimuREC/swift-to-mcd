//
//  Complex.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 09.04.2022.
//

import Foundation
import ArgumentParser

struct Complex: ParsableCommand {
	
	static var configuration: CommandConfiguration {
		.init(
			commandName: "complex",
			abstract: "Executes Convert + Generate"
		)
	}
	
	func run() throws {
		try Convert().run()
		try Generate().run()
	}
}
