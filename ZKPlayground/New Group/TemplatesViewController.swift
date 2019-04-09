//
//  TemplatesViewController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 4/5/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class TemplatesViewController: NSViewController {
    
    private var templatePaths: [String]? {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.templatePaths = Bundle.main.paths(forResourcesOfType: "code", inDirectory: "Templates")
        
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
        
        return 0
        return templatePaths?.count ?? 0
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
