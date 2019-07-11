//
//  RepoCell.swift
//  MVVM_POC
//
//  Created by Moayad Al kouz on 7/10/19.
//  Copyright © 2019 Moayad Al kouz. All rights reserved.
//

import UIKit

class RepoCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stargazersCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
