//
//  FileViewController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/20/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class FileViewController: NSViewController {
    
    @IBOutlet weak var fileView: NSOutlineView!
    
    private var rootItem: FileItem? {
        didSet {
            
            self.fileWatcher?.pause()
            self.fileWatcher = nil
            
            if let url = rootItem?.url {
                self.fileWatcher = SwiftFSWatcher([url.path])
                self.fileWatcher?.watch({ files in
                    try? self.showFileItems(root: url)
                })
            }
        }
    }
    
    private var fileWatcher: SwiftFSWatcher? = nil
    
    /// Hack. Forces SelectionDidChange to ignore programmatically set selection
    private var ignoreSelection: Bool = false
    
//    override var representedObject: Any? {
//        didSet {
//            
//            if let textDocument = representedObject as? TextDocument, let project = textDocument.project {
//                // RootItem is nil, the outlineview is currently empty.
//                // A new project was opened, with textDocument as default document
//                
//                try? self.showFileItems(root: project.workDirectory, selectItem: textDocument.fileURL)
//                
//            } else if let project = representedObject as? ProjectDocument {
//                // RootItem is nil, the outlineview is currently empty.
//                // A new project with no default document was opened,
//                // Projectfile is opened by default
//                
//                try? self.showFileItems(root: project.workDirectory, selectItem: project.fileURL)
//                
//            }
//        }
//    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        try? self.showFileItems(root: URL(fileURLWithPath: "~//Development//Temp"), selectItem: nil)
    }
    
    @IBAction func fileViewDoubleClick(_ sender: NSOutlineView) {
        guard let item = sender.item(atRow: sender.clickedRow) as? FileItem, item.isDirectory == true else { return }
        
        if sender.isItemExpanded(item) {
            sender.collapseItem(item)
        } else {
            sender.expandItem(item)
        }
    }
    
    
    /// Adds file tree to view and selects selectItem
    func showFileItems(root: URL, selectItem: URL? = nil) throws {
        
        // 1. If the file view is being reloaded, a file must already be selected
        //    Restore selection.
        var urlToSelect = selectItem
        let row = self.fileView.selectedRow
        if row != -1, let previouslySelectedItem = self.fileView.item(atRow: row) as? FileItem {
            urlToSelect = previouslySelectedItem.url
        }
        
        // 2. If the file view is being reloaded, some directories might be expanded
        let expandedDirectories = self.expandedURLs()
        
        // 3. Create root item. Rest of tree will be created lazily
        rootItem = try FileItem(url: root)
        
        // 4. Show files in view and expand root
        fileView.reloadData()
        fileView.expandItem(rootItem)
        
        // 5. Expand perviously expanded directories using the directories fetched in step 2
        expandItems(urls: expandedDirectories)
        
        // 6. Select item
        if let urlToSelect = urlToSelect, let path = rootItem?.find(file: urlToSelect) {
            
            for item in path {
                fileView.expandItem(item)
            }
            
            let rowToSelect = fileView.row(forItem: path.last)
            guard rowToSelect != -1 else { return }
            ignoreSelection = true
            fileView.selectRowIndexes([rowToSelect], byExtendingSelection: false)
        }
    }
    
    private func expandedURLs() -> [URL] {
        var urls = [URL]()
        let numberOfItems = fileView.numberOfRows
        for index in 0 ..< numberOfItems {
            let item = fileView.item(atRow: index)
            if fileView.isItemExpanded(item) {
                urls.append((item as! FileItem).url)
            }
        }
        return urls
    }
    
    private func expandItems(urls: [URL]) {
        let numberOfItems = fileView.numberOfRows
        for index in 0 ..< numberOfItems {
            let item = fileView.item(atRow: index)
            if urls.contains((item as! FileItem).url) {
                fileView.expandItem(item)
            }
        }
    }
}

extension FileViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? FileItem else { return nil }
        guard let view: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileCell"), owner: self) as? NSTableCellView else {
            return nil
        }
        view.textField?.stringValue = item.localizedName
        view.imageView?.image = item.icon
        return view
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        
        guard let item = item as? FileItem, item.isDirectory == false else { return false }
        return true
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        
//        if ignoreSelection == true {
//            ignoreSelection = false
//            return
//        }
//
//        guard let outlineView = notification.object as? NSOutlineView else { return }
//
//        let selectedIndex = outlineView.selectedRow
//        guard let item = outlineView.item(atRow: selectedIndex) as? FileItem, let controller = view.window?.windowController else {
//            return }
//
//        let oldDocument = representedObject
//        if let oldDocument = oldDocument as? NSDocument {
//            oldDocument.save(self)
//        }
//
//        DocumentController.shared.openDocument(withContentsOf: item.url, display: false) { document, isAlreadyOpen, error in
//            guard error == nil, let document = document else { return }
//            DispatchQueue.main.async {
//                (DocumentController.shared as! DocumentController).replace(document, inController: controller)
//                if let oldDocument = oldDocument as? NSDocument, oldDocument.fileURL != document.fileURL {
//                    oldDocument.close()
//                }
//            }
//        }
    }
}

extension FileViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        // If root is not set, don't show anything
        guard rootItem != nil else { return 0 }
        
        // item is nil if requesting root
        guard let item = item as? FileItem else { return 1 }
        
        return item.children.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? FileItem else {
            assertionFailure()
            return false
        }
        return item.isDirectory
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item as? FileItem else {
            return rootItem!
        }
        return item.children[index]
    }
}

