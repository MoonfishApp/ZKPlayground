//
//  Document.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/20/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    var string: String = ""
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
        
        windowController.document = self
    }

    override func data(ofType typeName: String) throws -> Data {
        
        guard let data = self.string.data(using: .utf8) else {
            throw ZKError.cannotSaveFile(self.fileURL?.path ?? "of type: \(typeName)")
        }
        
        return data
    }

    override func read(from data: Data, ofType typeName: String) throws {
        
        guard let string = String(bytes: data, encoding: .utf8) else {
            throw ZKError.cannotOpenFile(self.fileURL?.path ?? "of type: \(typeName)")
        }
        
        self.string = string
    }


}

