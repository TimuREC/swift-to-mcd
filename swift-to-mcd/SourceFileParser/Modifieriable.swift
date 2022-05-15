//
//  Modifieriable.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 15.05.2022.
//

import Foundation
import SwiftSemantics

protocol Modifieriable {
	var modifiers: [Modifier] { get }
}

extension Modifieriable {
	var isPrivate: Bool {
		modifiers.contains(where: {$0.name == "private" })
	}
}

// MARK: - SwiftSemantic objects + Modifieriable

extension Variable: Modifieriable {}
extension Function: Modifieriable {}
