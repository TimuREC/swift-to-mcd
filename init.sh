#!/bin/zsh

git submodule update --init
cd submodules/SwiftSemantics && git checkout 7690606eec5db6b089d6a5d252013ee07cade323

local MMDC="$(which mmdc)"
if [ "$MMDC" = "" ]; then
	echo "Mermaid-cli not found in PATH"
	echo "Please install it: brew install mermaid-cli"
	exit 1
fi

open ../../swift-to-mcd.xcodeproj