//
//  SwiftSourceFileParser.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 27.03.2022.
//

import Foundation

struct SwiftSourceFileParser: SourceFileParser {
	
	func parseFiles(on urls: [URL], handler: (SourceFile) -> Void) {
		urls.forEach { url in
			guard let string = try? String(contentsOf: url) else { return }
			var file = SourceFile(path: url.path)
			let codeObjects = parseFile(string)
			file.set(codeObjects.mermaidize)
			handler(file)
		}
	}
}

// MARK: - Private

private extension SwiftSourceFileParser {
	
	func parseFile(_ text: String) -> [SwiftCodeObject] {
		var objects: [SwiftCodeObject] = []
		let lines = text.components(separatedBy: .newlines)
		
		var isInsideFuncNow = false
		var isInsideClassNow = false
		var funcBraceCounter = 0
		var classBraceCounter = 0
		
		var methods: [String] = []
		var parameters: [String] = []
		
		var currentObject: SwiftCodeObject?
		
		lines.forEach { line in
			let clearLine = line.trimmingCharacters(in: .whitespaces)
			if isInsideFuncNow {
				if ["}", "}()"].contains(where: { clearLine.hasPrefix($0) }) {
					funcBraceCounter -= 1
					if funcBraceCounter == 0 {
						isInsideFuncNow = false
					}
				}
				if clearLine.contains("{") {
					funcBraceCounter += 1
					isInsideFuncNow = true
				}
			} else if isInsideClassNow, clearLine == "}" {
				classBraceCounter -= 1
				if classBraceCounter == 0 {
					isInsideClassNow = false
					currentObject?.set(parameters: parameters)
					currentObject?.set(methods: methods)
					guard let object = currentObject else { return }
					objects.append(object)
					currentObject = nil
					methods.removeAll()
					parameters.removeAll()
					return
				}
			}
			
			guard clearLine.isNeedBeParsed, !isInsideFuncNow else { return }
			
			if clearLine.isFunc {
				if !clearLine.hasPrefix(SwiftAccessModifier.private.rawValue) {
					methods.append(clearLine.trimmingCharacters(in: .punctuationCharacters))
				}
				if clearLine.hasSuffix("{") {
					isInsideFuncNow = true
					funcBraceCounter += 1
				}
			} else if clearLine.isParameter {
				if !clearLine.hasPrefix(SwiftAccessModifier.private.rawValue),
				   let parameter = clearLine.components(separatedBy: " =").first?.trimmingCharacters(in: .punctuationCharacters) {
					parameters.append(parameter)
				}
				if clearLine.contains("{") {
					isInsideFuncNow = true
					funcBraceCounter += 1
				}
			} else if clearLine.isClass {
				let words = clearLine.components(separatedBy: .whitespaces)
				var isClassNameNow = false
				var isClassHasParents = false
				var className: String?
				var type: SwiftCodeObjectType?
				var accessModifier: SwiftAccessModifier?
				var inheritage: [String] = []
				words.forEach { word in
					if word == "{" {
						isInsideClassNow = !clearLine.hasSuffix("}")
						classBraceCounter += 1
					} else if isClassNameNow {
						className = word.trimmingCharacters(in: .punctuationCharacters)
						isClassNameNow = false
						isClassHasParents = word.hasSuffix(":")
					} else if isClassHasParents {
						let parent = word.trimmingCharacters(in: .punctuationCharacters)
						if !parent.isEmpty { inheritage.append(parent) }
					} else if let modifier = SwiftAccessModifier(rawValue: word) {
						accessModifier = modifier
					} else if let objectType = SwiftCodeObjectType(rawValue: word) {
						type = objectType
						isClassNameNow = true
					}
				}
				if isClassHasParents {
					isClassHasParents = false
				}
				if let className = className,
				   let type = type {
					currentObject = SwiftCodeObject(
						name: className,
						accessModifier: accessModifier ?? .internal,
						type: type,
						inheritage: inheritage,
						parameters: [],
						methods: []
					)
				}
			}
		}
		
		return objects
	}
}

private extension String {
	
	var isFunc: Bool {
		let words = self.components(separatedBy: .whitespaces)
		for (index, word) in words.enumerated() where index < 4 {
			if word == "func" || word.hasPrefix("init") {
				return true
			}
		}
		return false
	}
	
	var isParameter: Bool {
		let words = self.components(separatedBy: .whitespaces)
		for (index, word) in words.enumerated() where index < 4 {
			if ["var", "let"].contains(word) {
				return true
			}
		}
		return false
	}
	
	var isClass: Bool {
		let words = self.components(separatedBy: .whitespaces)
		for (index, word) in words.enumerated() where index < 3 {
			if ["class", "protocol", "extension"].contains(word)  {
				return true
			}
		}
		return false
	}
	
	var isNeedBeParsed: Bool {
		!isEmpty &&
		!hasPrefix("//") &&
		!hasPrefix("import ")
	}
}
