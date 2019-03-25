//
//  SolarizedLightTheme.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/22/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation
import SourceEditor
import SavannaKit
import AppKit

struct  SolarizedLight: SourceCodeTheme {
    
    public init() {
        
    }
    
    private static var lineNumbersColor: Color {
        return NSColor(rgb: 0x657b83)
    }
    
    public let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: Font(name: "Menlo", size: 14)!, textColor: lineNumbersColor)
    
    public let gutterStyle: GutterStyle = GutterStyle(backgroundColor: NSColor(rgb: 0xfdf6e3), minimumWidth: 32)
    
    public let font = Font(name: "Menlo", size: 14)!
    
    public let backgroundColor = NSColor(rgb: 0xfdf6e3)
    
    public func color(for syntaxColorType: SourceCodeTokenType) -> Color {
    
        switch syntaxColorType {
        case .plain:
            return NSColor(rgb: 0x657b83)
            
        case .number:
            return NSColor(rgb: 0xdc322f)
            
        case .string:
            return NSColor(rgb: 0x2aa198)
            
        case .identifier:
            return .blue //NSColor(rgb: 0xb58900)
            
        case .keyword:
            return .red //NSColor(rgb: 0x859900)
            
        case .comment:
            return NSColor(rgb: 0x93a1a1)
            
        case .editorPlaceholder:
            return NSColor(rgb: 0x93a1a1)
        }
        
    }
    
    
    
}
/*
{
    "text" : {
        "color" : "#657b83"
    },
    "insertionPoint" : {
        "color" : "#657b83"
    },
    "invisibles" : {
        "color" : "#eee8d5"
    },
    "background" : {
        "color" : "#fdf6e3"
    },
    "lineHighlight" : {
        "color" : "#eee8d5"
    },
    "selection" : {
        "color" : "#93a1a1",
        "usesSystemSetting" : false
    },
    "keywords" : {
        "color" : "#859900"
    },
    "commands" : {
        "color" : "#cb4b16"
    },
    "types" : {
        "color" : "#268bd2"
    },
    "attributes" : {
        "color" : "#6c71c4"
    },
    "variables" : {
        "color" : "#b58900"
    },
    "values" : {
        "color" : "#d33682"
    },
    "numbers" : {
        "color" : "#dc322f"
    },
    "strings" : {
        "color" : "#2aa198"
    },
    "characters" : {
        "color" : "#dc322f"
    },
    "comments" : {
        "color" : "#93a1a1"
    },
}
*/
