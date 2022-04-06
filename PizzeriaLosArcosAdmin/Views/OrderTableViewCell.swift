//
//  OrderTableViewCell.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 29/03/22.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var folioLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var clientPhoneLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeEstimatedDelivery: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewCell.dropShadow()
        viewCell.layer.cornerRadius = 12
        viewCell.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
