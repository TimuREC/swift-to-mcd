//
//  String+typeFormat.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 15.05.2022.
//

import Foundation

extension String {
	
	var typeFormat: [String] {
		return components(separatedBy: " & ").map {
			let type = $0.replacingOccurrences(of: "?", with: "")
				.replacingOccurrences(of: "[", with: "")
				.replacingOccurrences(of: "]", with: "")
				.replacingOccurrences(of: ".", with: "_")
			if (hasPrefix("(") && contains("->")) || hasPrefix("@escaping") {
				return "Completion"
			} else if type.contains("("),
					  let type = type.components(separatedBy: "(").first?
						.components(separatedBy: "<").first?
						.components(separatedBy: ":").first {
				return type
			} else if type.hasPrefix("Set<") || type.hasPrefix("Array<") {
				return type.replacingOccurrences(of: "<", with: "_").replacingOccurrences(of: ">", with: "")
			}
			return type
		}
	}
}
