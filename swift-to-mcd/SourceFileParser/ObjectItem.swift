//
//  ObjectItem.swift
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
