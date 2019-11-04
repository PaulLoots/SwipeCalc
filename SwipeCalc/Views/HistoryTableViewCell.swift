//
//  HistoryTableViewCell.swift
//  SwipeCalc
//
//  Created by Paul Loots on 2019/10/16.
//  Copyright © 2019 Paul Loots. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet var historyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
