//
//  SwiftSourceFileParser.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 27.03.2022.
//

import Foundation
import SwiftSemantics
import SwiftSyntax

struct SwiftSourceFileParser: SourceFileParser {
	
	func parseFiles(on urls: [URL], handler: (SourceFile) -> Void) {
		urls.forEach { url in
			var file = SourceFile(path: url.path)
			guard let tree = try? SyntaxParser.parse(url, diagnosticEngine: nil) else { return }
			let collector = DeclarationCollector()
			collector.walk(tree)
			file.set(collector.mermaidize)
			handler(file)
		}
	}
}

// MARK: - Private

private extension DeclarationCollector {

	var mermaidize: String {
		var result = ""
		classes.forEach { obj in
			guard !obj.modifiers.contains(where: {$0.name == "private" }) else { return }
			obj.inheritance.forEach { parent in
				result.append("\(parent) <-- \(obj.name)\n")
			}
			if obj.inheritance.isEmpty {
				result.append("class \(obj.name){\n\t\n}\n")
			}
		}
		extensions.forEach { obj in
			guard !obj.modifiers.contains(where: {$0.name == "private" }) else { return }
			obj.inheritance.forEach { parent in
				result.append("\(parent) <-- \(obj.extendedType)\n")
			}
		}
		structures.forEach { obj in
			guard !obj.modifiers.contains(where: {$0.name == "private" }) else { return }
			obj.inheritance.forEach { parent in
				result.append("\(parent) <-- \(obj.name)\n")
			}
			if obj.inheritance.isEmpty {
				result.append("class \(obj.name){\n\t<<struct>>\n}\n")
			}
		}
		enumerations.forEach { obj in
			guard !obj.modifiers.contains(where: {$0.name == "private" }) else { return }
			obj.inheritance.forEach { parent in
				result.append("\(parent) <-- \(obj.name)\n")
			}
			if obj.inheritance.isEmpty {
				result.append("class \(obj.name){\n\t<<enum>>\n}\n")
			}
		}
		return result
	}
}
