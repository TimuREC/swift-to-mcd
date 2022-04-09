//
//  SwiftSourceFileParser.swift
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
