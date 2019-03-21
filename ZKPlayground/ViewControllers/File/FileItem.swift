//
//  FileItem.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/20/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

final class FileItem: NSObject {
    let url: URL
    
    let localizedName: String
    var icon: NSImage? { return NSWorkspace.shared.icon(forFile: url.path) }
    let isDirectory: Bool
    
    init(url: URL) throws {
        
        let filemanager = FileManager.default
        var isDirectory: ObjCBool = false
        guard filemanager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            throw ZKError.fileNotFound(url.path)
        }
        
        self.url = url
        
        let fileResource = try url.resourceValues(forKeys: [URLResourceKey.nameKey])
        localizedName = fileResource.localizedName ?? fileResource.name ?? "<UNKNOWN>"
        self.isDirectory = isDirectory.boolValue
    }
    
    lazy var children: [FileItem] = {
        
        let fileManager = FileManager.default
        let filelist = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
        
        guard isDirectory == true, fileManager.fileExists(atPath: url.path), let files = filelist else {
            return [FileItem]()
        }
        
        let sortedFiles = files.sorted(by: { $0.path < $1.path })
        var _children = [FileItem]()
        for file in sortedFiles {
            if let item = try? FileItem(url: file) {
                _children.append(item)
            }
        }
        return _children
    }()
    
    /// Returns path to item. Last item is the item being searched
    /// Usage: findFile(url: ...) (without setting path)
    func find(file url: URL, path: [FileItem] = [FileItem]()) -> [FileItem]? {
        
        var path = path
        path.append(self)
        if self.url.standardizedFileURL == url.standardizedFileURL {
            return path
        } else {
            for child in children {
                if let foundPath = child.find(file: url, path: path) {
                    return foundPath
                }
            }
        }
        return nil
    }
    
    static func ==(lhs: FileItem, rhs: FileItem) -> Bool {
        return lhs.url == rhs.url
    }
}

