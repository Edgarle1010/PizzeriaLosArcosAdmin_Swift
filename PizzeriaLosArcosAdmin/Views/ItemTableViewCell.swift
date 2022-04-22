//
//  ItemTableViewCell.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 21/01/22.
//

import UIKit
import SwipeCellKit

class ItemTableViewCell: SwipeTableViewCell {
    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var extraIngredientView: UIStackView!
    @IBOutlet weak var extraIngredientsLabel: UILabel!
    @IBOutlet weak var commentsView: UIStackView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
