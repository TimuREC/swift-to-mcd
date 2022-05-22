# swift-to-mcd
CLI инструмент для построения диаграмм классов из исходного кода на Swift

## Информация для пользователей
- Скомпилированный инструмент доступен в [Releases]
- Для работы требуется установка [mermaid-cli], также Вы можете сгенерировать схему из содержимого *result.mcd* онлайн на [Mermaid live]

## Пример сгенерированной диаграммы по данному проекту
```mermaid
classDiagram

class String{
	var typeFormat: [String]
	
}

class Modifieriable{
	<<protocol>>

	var modifiers: [Modifier]
	
}
Modifier --o Modifieriable

class Modifieriable{
	var isPrivate: Bool
	
}
Bool --o Modifieriable

Modifieriable <|-- Variable
class Variable{
	
}

Modifieriable <|-- Function
class Function{
	
}

SourceFileParser <|-- SwiftSourceFileParser
class SwiftSourceFileParser{
	<<struct>>

	
	func parseFiles(on urls: [URL], handler: (SourceFile) -> Void)
}
Completion <-- SwiftSourceFileParser
URL <-- SwiftSourceFileParser

class SourceFileParser{
	<<protocol>>

	
	func parseFiles(on urls: [URL], handler: (SourceFile) -> Void)
}
URL <-- SourceFileParser
Completion <-- SourceFileParser

String <|-- ObjectType
class ObjectType{
	<<enum>>

	case `class`
	case `extension`
	case `struct`
	case `enum`
	case `protocol`
	
}

Modifieriable <|-- ObjectItem
class ObjectItem{
	<<protocol>>

	var objectType: ObjectType
	var name: String
	var inheritance: [String]
	
}
String --o ObjectItem
ObjectType --o ObjectItem

class ObjectItem{
	var mmdInheritance: String
	var mmdDeclaration: String
	
}
String --o ObjectItem

ObjectItem <|-- Class
class Class{
	let objectType: 
	
}

ObjectItem <|-- Extension
class Extension{
	let objectType: 
	var name: String
	
}
String --o Extension

ObjectItem <|-- Structure
class Structure{
	let objectType: 
	
}

ObjectItem <|-- Enumeration
class Enumeration{
	let objectType: 
	
}

ObjectItem <|-- Protocol
class Protocol{
	let objectType: 
	
}

ParsableCommand <|-- Complex
class Complex{
	<<struct>>

	var configuration: CommandConfiguration
	
	func run() throws
}
CommandConfiguration --o Complex

ParsableCommand <|-- Generate
class Generate{
	<<struct>>

	var configuration: CommandConfiguration
	
	func run() throws
}
CommandConfiguration --o Generate

ParsableCommand <|-- Convert
class Convert{
	<<struct>>

	var configuration: CommandConfiguration
	
	func run() throws
}
CommandConfiguration --o Convert
Converter --o Convert

class Converter{
	
	func start()
}
SourceFileParser --o Converter
IFileManager --o Converter

class SourceFile{
	<<struct>>

	let path: String
	
	mutating func set(_ mermaidDescription: String)
}
String --o SourceFile

ParsableCommand <|-- SwiftToMCD
class SwiftToMCD{
	<<struct>>

	var configuration: CommandConfiguration
	
}
CommandConfiguration --o SwiftToMCD

class IFileManager{
	<<protocol>>

	var currentDirectoryPath: String
	
	func scan(path: String, for fileExtension: String) -> [URL]
	func save(_ sourceFiles: [SourceFile], at path: String)
}
String --o IFileManager
SourceFile <-- IFileManager

IFileManager <|-- FileManager
class FileManager{
	
	func scan(path: String, for fileExtension: String) -> [URL]
	func save(_ sourceFiles: [SourceFile], at path: String)
}
String <-- FileManager
SourceFile <-- FileManager
```

## Author
Timur Begishev\
telegram: [@t1murec]

## License
[Apache License 2.0]

[Releases]: <https://github.com/TimuREC/swift-to-mcd/releases>
[Mermaid live]: <https://mermaid.live/>
[mermaid-cli]: <https://github.com/mermaid-js/mermaid-cli>
[@t1murec]: <https://t.me/t1murec>
[Apache License 2.0]: <https://github.com/TimuREC/swift-to-mcd/blob/main/LICENSE>
