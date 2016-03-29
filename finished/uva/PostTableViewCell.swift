//
//  PostTableViewCell.swift
//  uva
//
//  Created by Andrew Carter on 3/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    // MARK: - Static Properties
    
    static let reuseIdentifier = "PostTableViewCell"
    
    // MARK: - Properties
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    // MARK: - Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clearOutlets()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        clearOutlets()
    }
    
    // MARK: - Instance Methods
    
    func clearOutlets() {
        accessoryType = .None
        titleLabel.text = nil
        detailLabel.text = nil
    }
    
}
