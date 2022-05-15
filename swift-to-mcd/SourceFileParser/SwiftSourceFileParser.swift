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
import enum SwiftSyntax.SyntaxParser

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
	
	func parseObject(parentObjName: String, lines: [String], lineNumber: Int) -> (obj: [String], line: Int) {
		var subObj = ""
		var actualName = ""
		var currentLine = lineNumber
		var braces = 0
		var objects: [String] = []
		
		
		while currentLine < lines.count {
			let line = lines[currentLine]
			if currentLine == lineNumber {
				let subObjName = line.className
				actualName = "\(parentObjName)_\(subObjName)"
				subObj = line.replacingOccurrences(of: " \(subObjName)", with: " \(actualName)") + "\n"
				if subObj.contains("{") { braces += 1 }
				currentLine += 1
				continue
			}
			if braces > 0, line.isObject {
				let result = parseObject(parentObjName: actualName, lines: lines, lineNumber: currentLine)
				objects += result.obj
				currentLine = result.line
				continue
			}
			subObj.append(line + "\n")
			if line.contains("}") { braces -= 1 }
			if line.contains(" {") { braces += 1 }
			currentLine += 1
			if braces == 0 {
				objects.append(subObj)
				break
			}
		}
		return (objects, currentLine)
	}
	
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
				let result = parseObject(parentObjName: currentClass.className, lines: lines, lineNumber: lineNumber)
				objects += result.obj
				lineNumber = result.line
			}
			
			currentClass.append(line + "\n")
			if line.contains("}") { classBraceCounter -= 1 }
			if line.contains(" {") { classBraceCounter += 1 }
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
	
	static let objectKeywords = [
		"class",
		"protocol",
		"extension",
		"enum",
		"struct"
	]
	
	var isObject: Bool {
		return trimmingCharacters(in: .whitespaces)
			.components(separatedBy: .whitespaces)
			.suffix(3)
			.contains(where: String.objectKeywords.contains)
	}
	
	var isNeedBeParsed: Bool {
		!isEmpty &&
		!hasPrefix("//") &&
		!hasPrefix("import ")
	}
	
	var className: String {
		guard let words = components(separatedBy: .newlines).first?.components(separatedBy: .whitespaces),
			  let index = words.firstIndex(where: String.objectKeywords.contains) else { return "" }
		return words[index + 1].trimmingCharacters(in: .punctuationCharacters)
	}
}

private extension DeclarationCollector {
	
	var mermaidizeClass: String {
		var objectName = ""
		var result = ([
			classes,
			extensions,
			structures,
			enumerations,
			protocols
		] as [[ObjectItem]]).flatMap({ $0 }).filter({ !$0.isPrivate }).reduce(into: "") { partialResult, obj in
			objectName = obj.name
			partialResult.append(obj.mmdInheritance)
			partialResult.append(obj.mmdDeclaration)
			guard obj is Enumeration else { return }
			enumerationCases.forEach {
				partialResult.append("\t\($0.description)\n")
			}
		}
		guard !result.isEmpty else { return result }
		var aggregations: Set<String> = []
		var associations: Set<String> = []
		
		variables.forEach {
			for type in $0.typeAnnotation?.typeFormat ?? [] where type != objectName {
				aggregations.insert(type)
			}
			guard !$0.isPrivate else { return }
			result.append("\t\($0.keyword) \($0.name): \($0.typeAnnotation ?? "")\n")
		}
		result.append("\t\n")
		initializers.flatMap({ $0.parameters }).flatMap({ $0.type?.typeFormat ?? [] }).filter({ !aggregations.contains($0) && $0 != objectName }).forEach {
			associations.insert($0)
		}
		functions.filter({ !$0.isPrivate }).forEach {
			result.append("\t\($0.description)\n")
			$0.signature.input.flatMap({ $0.type?.typeFormat ?? [] }).filter({ !aggregations.contains($0) && $0 != objectName }).forEach {
				associations.insert($0)
			}
		}
		result.append("}\n")
		aggregations.forEach { result.append("\($0) --o \(objectName)\n") }
		associations.forEach { result.append("\($0) <-- \(objectName)\n") }
		result.append("\n")
		return result
	}
}
