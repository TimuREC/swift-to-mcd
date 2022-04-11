# swift-to-mcd
CLI инструмент для построения диаграмм классов из исходного кода на Swift

## Информация по запуску проекта
- Склонируйте репозиторий и запустите [init.sh]
- Для работы требуется установка [mermaid-cli]

## Пример сгенерированной диаграммы по данному проекту
```mermaid
classDiagram

SourceFileParser <|-- SwiftSourceFileParser
class SwiftSourceFileParser{
	<<struct>>

	
	func parseFiles(on urls: [URL], handler: (SourceFile) -> Void)
}
URL <-- SwiftSourceFileParser
Completion <-- SwiftSourceFileParser

class SourceFileParser{
	<<protocol>>

	
	func parseFiles(on urls: [URL], handler: (SourceFile) -> Void)
}
Completion <-- SourceFileParser
URL <-- SourceFileParser

ParsableCommand <|-- Complex
class Complex{
	<<struct>>

	var configuration: CommandConfiguration
	
	func run() throws
}
CommandConfiguration <-- Complex

ParsableCommand <|-- Generate
class Generate{
	<<struct>>

	var configuration: CommandConfiguration
	
	func run() throws
}
CommandConfiguration <-- Generate

ParsableCommand <|-- Convert
class Convert{
	<<struct>>

	var configuration: CommandConfiguration
	
	func run() throws
}
CommandConfiguration <-- Convert

class Converter{
	
	func start()
}
IFileManager --o Converter
SourceFileParser --o Converter

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
CommandConfiguration <-- SwiftToMCD

class IFileManager{
	<<protocol>>

	var currentDirectoryPath: String
	
	func scan(path: String, for fileExtension: String) -> [URL]
	func save(_ sourceFiles: [SourceFile], at path: String)
}
SourceFile <-- IFileManager
String <-- IFileManager

IFileManager <|-- FileManager
class FileManager{
	
	func scan(path: String, for fileExtension: String) -> [URL]
	func save(_ sourceFiles: [SourceFile], at path: String)
}
SourceFile <-- FileManager
String <-- FileManager

```

## Author
Timur Begishev\
telegram: [@t1murec]

## License
[Apache License 2.0]

[init.sh]: <https://github.com/TimuREC/swift-to-mcd/blob/main/init.sh>
[mermaid-cli]: <https://github.com/mermaid-js/mermaid-cli>
[@t1murec]: <https://t.me/t1murec>
[Apache License 2.0]: <https://github.com/TimuREC/swift-to-mcd/blob/main/LICENSE>
