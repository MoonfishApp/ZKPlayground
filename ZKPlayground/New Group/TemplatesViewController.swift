//
//  TemplatesViewController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 4/5/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class TemplatesViewController: NSViewController {
    
    @IBOutlet weak var platformCollectionView: NSCollectionView!
    @IBOutlet weak var templateCollectionView: NSCollectionView!
    
    private var templatePaths: [String] {
        
        return Bundle.main.paths(forResourcesOfType: "code", inDirectory: "Templates")
    }
    
    private var platformPaths: [String] {
        
        let paths = Bundle.main.paths(forResourcesOfType: nil, inDirectory: "Templates").filter {
            
            var isDirectory: ObjCBool = false
            let _ = FileManager.default.fileExists(atPath: $0, isDirectory: &isDirectory)
            return isDirectory.boolValue == true
        }
        return paths
    }
    
    private var platforms: [String] {
        
        return self.platformPaths.map { return URL(fileURLWithPath: $0).lastPathComponent }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let p = self.platforms
        print(p)
    }
    
    @IBAction func cancel(_ sender: Any?) {
        view.window?.close()
    }
    
    @IBAction func okay(_ sender: Any?) {
        // Show save
        // Create new project directory, copy and rename template file
        view.window?.close()
    }
    
}

extension TemplatesViewController: NSCollectionViewDelegate {
    
}
/*
extension TemplatesViewController: NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    
        if collectionView === self.platformCollectionView {
            return platformPaths.count
        } else if collectionView === self.templateCollectionView {
            return templatePaths.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: <#T##NSUserInterfaceItemIdentifier#>, for: <#T##IndexPath#>)
 
        
        
        guard let cell = templateCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("TemplateCollectionViewItem"), for: indexPath) as? TemplateCollectionViewItem else {
            assertionFailure()
            return NSCollectionViewItem()
        }
        
        let template = item(at: indexPath)
        
        cell.imageView?.image = template.image
        cell.textField?.stringValue = template.name
        cell.erc.stringValue = template.standard
        cell.descriptionTextField.stringValue = template.description ?? ""
        cell.moreInfoButton.isHidden = template.moreInfoUrl.isEmpty
        return cell
    }
    
    
}*/
