//
//  MessageCell.swift
//  chat
//
//  Created by administrator on 08/01/2022.
//

import UIKit
import SDWebImage
class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var convImg: UIImageView!
    @IBOutlet weak var convName: UILabel!
    @IBOutlet weak var convMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        convImg.layer.cornerRadius = convImg.frame.size.height / 2
        convImg.layer.masksToBounds = true
        
        // Initialization code
    }
    
    func configure(with model:Conversation) {
        convName.text = model.name
        convMessage.text = model.latestMessage.message
        
        let path = "images/\(model.otherEmail)_profile_picture.png"
        
        StorageManager.shared.downloadURL(for: path, completion: {
            [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.convImg.sd_setImage(with: url)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
