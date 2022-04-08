//
//  SourceFile.swift
//  swift-to-mcd
//
//  Created by Timur Begishev on 27.03.2022.
//

import Foundation

struct SourceFile {
	
	let path: String
	private(set) var mermaidDescription: String = ""
	
	init(path: String) {
		self.path = path
	}
	
	mutating func set(_ mermaidDescription: String) {
		self.mermaidDescription = mermaidDescription
	}
}
