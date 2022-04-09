//
//  main.swift
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

