//
//  ObjectItem.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 15.05.2022.
//

import Foundation
import struct SwiftSemantics.Class
import struct SwiftSemantics.Extension
import struct SwiftSemantics.Structure
import struct SwiftSemantics.Enumeration
import struct SwiftSemantics.Protocol

enum ObjectType: String {
	case `class`
	case `extension`
	case `struct`
	case `enum`
	case `protocol`
}

protocol ObjectItem: Modifieriable {
	static var objectType: ObjectType { get }
	var name: String { get }
	var inheritance: [String] { get }
}

extension ObjectItem {
	
	var mmdInheritance: String {
		inheritance.reduce(into: "") { partialResult, parent in
			parent.typeFormat.forEach {
				partialResult.append("\($0) <|-- \(name)\n")
			}
		}
	}
	
	var mmdDeclaration: String {
		var result = "class \(name){\n"
		if ![ObjectType.class, .extension].contains(Self.objectType) {
			result.append("\t<<\(Self.objectType.rawValue)>>\n\n")
		}
		return result
	}
}

// MARK: - SwiftSemantic objects + ObjectItem

extension Class: ObjectItem {
	static let objectType = ObjectType.class
}

extension Extension: ObjectItem {
	static let objectType = ObjectType.extension
	
	var name: String {
		extendedType.replacingOccurrences(of: ".", with: "_")
	}
}

extension Structure: ObjectItem {
	static let objectType = ObjectType.struct
}

extension Enumeration: ObjectItem {
	static let objectType = ObjectType.enum
}

extension Protocol: ObjectItem {
	static let objectType = ObjectType.protocol
}
