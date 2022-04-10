# swift-to-mcd
CLI инструмент для построения диаграмм классов из исходного кода на Swift

## Информация по запуску проекта
- Склонируйте репозиторий и запустите [init.sh]
- Для работы требуется установка [mermaid-cli]

## Пример сгенерированной диаграммы по данному проекту
```mermaid
  classDiagram

SourceFileParser <-- SwiftSourceFileParser
class SwiftSourceFileParser{
	<<struct>>

	
	func parseFiles(on urls: [URL], handler: (SourceFile) -> Void)
}

class SourceFileParser{
	<<protocol>>

	
	func parseFiles(on urls: [URL], handler: (SourceFile) -> Void)
}

ParsableCommand <-- Complex
class Complex{
	<<struct>>

	var configuration: CommandConfiguration
	
	func run() throws
}

ParsableCommand <-- Generate
class Generate{
	<<struct>>

	var configuration: CommandConfiguration
	
	func run() throws
}

ParsableCommand <-- Convert
class Convert{
	<<struct>>

	var configuration: CommandConfiguration
	
	func run() throws
}

class Converter{
	
	func start()
}

class SourceFile{
	<<struct>>

	let path: String
	
	mutating func set(_ mermaidDescription: String)
}

ParsableCommand <-- SwiftToMCD
class SwiftToMCD{
	<<struct>>

	var configuration: CommandConfiguration
	
}

class IFileManager{
	<<protocol>>

	var currentDirectoryPath: String
	
	func scan(path: String, for fileExtension: String) -> [URL]
	func save(_ sourceFiles: [SourceFile], at path: String)
}

IFileManager <-- FileManager
class FileManager{
	
	func scan(path: String, for fileExtension: String) -> [URL]
	func save(_ sourceFiles: [SourceFile], at path: String)
}

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
