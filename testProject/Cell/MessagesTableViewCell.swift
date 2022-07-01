//
//  MessagesTableViewCell.swift
//  testProject
//
//  Created by MahyR Sh on 6/28/22.
//

import UIKit

protocol CutomCellDelegate{
    func updateTableView(row: Int)
}

class MessagesTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionWithImageLabel: UILabel!
    @IBOutlet weak var descriptionWithOutImageLabel: UILabel!
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var expandMessagesButton: UIButton!
    @IBOutlet weak var saveMessagesButton: UIButton!
    @IBOutlet weak var shareMessagesButton: UIButton!
    @IBOutlet weak var cellView: UIView!
    
    var delegate: CutomCellDelegate?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func expandMessagesButtonTapped(_ sender: UIButton) {
        
        delegate?.updateTableView(row: sender.tag)
    }
}
