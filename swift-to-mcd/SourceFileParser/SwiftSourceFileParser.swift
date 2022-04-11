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
			guard let string = try? String(contentsOf: url) else { return }
			var file = SourceFile(path: url.path)
			let result = parseFile(string).reduce("") { partialResult, obj in
				guard let tree = try? SyntaxParser.parse(source: obj) else { return partialResult }
				let collector = DeclarationCollector()
				collector.walk(tree)
				return partialResult.appending(collector.mermaidizeClass)
			}
			file.set(result)
			handler(file)
		}
	}
}

// MARK: - Private

private extension SwiftSourceFileParser {
	
	func parseFile(_ text: String) -> [String] {
		let lines = text.components(separatedBy: .newlines)
		
		var classBraceCounter = 0
		var objects: [String] = []
		var currentClass = ""
		
		var lineNumber = 0
		while lineNumber < lines.count {
			let line = lines[lineNumber]
			guard line.isNeedBeParsed else { lineNumber += 1; continue }
			if classBraceCounter > 0, line.isObject {
				
				let subObjName = line.className
				let actualName = "\(currentClass.className)_\(subObjName)"
				var subObj = line.replacingOccurrences(of: subObjName, with: actualName) + "\n"
				
				lineNumber += 1
				var braces = subObj.contains("{") ? 1 : 0
				while lineNumber < lines.count {
					let subline = lines[lineNumber]
					subObj.append(subline + "\n")
					if subline.contains("}") { braces -= 1 }
					if subline.contains("{") { braces += 1 }
					lineNumber += 1
					if braces == 0 {
						objects.append(subObj)
						break
					}
				}
				continue
			}
			
			currentClass.append(line + "\n")
			if line.contains("}") { classBraceCounter -= 1 }
			if line.contains("{") { classBraceCounter += 1 }
			if classBraceCounter == 0 {
				objects.append(currentClass)
				currentClass.removeAll()
			}
			lineNumber += 1
		}
		return objects
	}
}

private extension String {
	
	var isObject: Bool {
		let words = self.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces)
		for (index, word) in words.enumerated() where index < 3 {
			guard ["class",
				   "protocol",
				   "extension",
				   "enum",
				   "struct"].contains(word) else { continue }
			return true
		}
		return false
	}
	
	var isNeedBeParsed: Bool {
		!isEmpty &&
		!hasPrefix("//") &&
		!hasPrefix("import ")
	}
	
	var className: String {
		guard let words = components(separatedBy: .newlines).first?.components(separatedBy: .whitespaces),
			  var index = words
				.firstIndex(where: {
			["class",
			 "protocol",
			 "extension",
			 "enum",
			 "struct"].contains($0)
		}) else { return "" }
		index += 1
		return words[index].trimmingCharacters(in: .punctuationCharacters)
	}
	
	var typeFormat: String {
		let type = replacingOccurrences(of: "?", with: "")
			.replacingOccurrences(of: "[", with: "")
			.replacingOccurrences(of: "]", with: "")
			.replacingOccurrences(of: ".", with: "_")
		if hasPrefix("(") || hasPrefix("@escaping") {
			return "Completion"
		} else if let type = type.components(separatedBy: "(").first?
					.components(separatedBy: "<").first?
					.components(separatedBy: ":").first{
			return type
		}
		return type
	}
 }

private extension DeclarationCollector {
	
	var mermaidizeClass: String {
		var result = ""
		var objectName = ""
		var aggregations: Set<String> = []
		var associations: Set<String> = []
		
		classes.forEach { obj in
			guard !obj.modifiers.contains(where: {$0.name == "private" }) else { return }
			objectName = obj.name
			obj.inheritance.forEach { parent in
				result.append("\(parent) <|-- \(objectName)\n")
			}
			result.append("class \(objectName){\n")
		}
		extensions.forEach { obj in
			guard !obj.modifiers.contains(where: {$0.name == "private" }) else { return }
			objectName = obj.extendedType.replacingOccurrences(of: ".", with: "_")
			obj.inheritance.forEach { parent in
				result.append("\(parent) <|-- \(objectName)\n")
			}
			result.append("class \(objectName){\n")
		}
		structures.forEach { obj in
			guard !obj.modifiers.contains(where: {$0.name == "private" }) else { return }
			objectName = obj.name
			obj.inheritance.forEach { parent in
				result.append("\(parent) <|-- \(objectName)\n")
			}
			result.append("class \(objectName){\n\t<<struct>>\n\n")
		}
		enumerations.forEach { obj in
			guard !obj.modifiers.contains(where: {$0.name == "private" }) else { return }
			objectName = obj.name
			obj.inheritance.forEach { parent in
				result.append("\(parent) <|-- \(objectName)\n")
			}
			result.append("class \(objectName){\n\t<<enum>>\n\n")
			enumerationCases.forEach {
				result.append("\t\($0.description)\n")
			}
		}
		protocols.forEach { obj in
			guard !obj.modifiers.contains(where: {$0.name == "private" }) else { return }
			objectName = obj.name
			obj.inheritance.forEach { parent in
				result.append("\(parent) <|-- \(objectName)\n")
			}
			result.append("class \(objectName){\n\t<<protocol>>\n\n")
		}
		if !result.isEmpty {
			initializers.forEach {
				$0.parameters.forEach {
					guard let type = $0.type else { return }
					aggregations.insert(type.typeFormat)
				}
			}
			variables.forEach {
				guard !$0.modifiers.contains(where: { $0.name == "private" }) else { return }
				let type = $0.typeAnnotation
				if let type = type, !aggregations.contains(type) {
					associations.insert(type.typeFormat)
				}
				result.append("\t\($0.keyword) \($0.name): \(type ?? "")\n")
			}
			result.append("\t\n")
			functions.forEach {
				guard !$0.modifiers.contains(where: { $0.name == "private" }) else { return }
				result.append("\t\($0.description)\n")
				$0.signature.input.forEach {
					guard let type = $0.type, !aggregations.contains(type) else { return }
					associations.insert(type.typeFormat)
				}
			}
			result.append("}\n")
			aggregations.forEach {
				result.append("\($0) --o \(objectName)\n")
			}
			associations.forEach {
				result.append("\($0) <-- \(objectName)\n")
			}
			result.append("\n")
		}
		return result
	}
}
