//
//  main.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 27.03.2022.
//

import Foundation
import ArgumentParser

struct SwiftToMCD: ParsableCommand {
	
	static var configuration: CommandConfiguration {
		.init(
			commandName: "swift-to-mcd",
			abstract: "Converts *.swift files to *.mcd and makes class diagram from it",
			version: "0.0.1",
			subcommands: [
				Complex.self,
				Convert.self,
				Generate.self
			],
			defaultSubcommand: Convert.self
		)
	}
}

SwiftToMCD.main()

