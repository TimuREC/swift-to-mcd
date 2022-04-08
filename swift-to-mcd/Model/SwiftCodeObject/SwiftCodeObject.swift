//
//  CodeObject.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 27.03.2022.
//

import Foundation

struct SwiftCodeObject {
	let name: String
	let accessModifier: SwiftAccessModifier
	let type: SwiftCodeObjectType
	let inheritage: [String]
	var parameters: [String]
	var methods: [String]
	
	mutating func set(parameters: [String]) {
		self.parameters = parameters
	}
	
	mutating func set(methods: [String]) {
		self.methods = methods
	}
	
	var mermaidize: String {
		guard accessModifier != .private else { return "" }
		var result = ""
		for parent in inheritage {
			result.append(contentsOf: "\(parent) <-- \(name)\n")
		}
		result += "class " + name + "{\n"
		if ![SwiftCodeObjectType.class, .extension].contains(type) {
			result.append(contentsOf: "\t<<\(type.rawValue)>>\n\n")
		}
		for parameter in parameters {
			result.append(contentsOf: "\t\(parameter)\n")
		}
		if !methods.isEmpty {
			result += "\n"
			for method in methods {
				result.append(contentsOf: "\t\(method)\n")
			}
		}
		return result + "}\n\n"
	}
}

// MARK: - Array + mermaidize

extension Array where Element == SwiftCodeObject {
	
	var mermaidize: String {
		reduce("classDiagram\n") { partialResult, codeObject in
			partialResult.appending(codeObject.mermaidize)
		}
	}
}
