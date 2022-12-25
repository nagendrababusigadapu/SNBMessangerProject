//
//  RecentTableViewCell.swift
//  SNBMessanger
//
//  Created by Syamala on 10/07/22.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCounterLabel: UILabel!
    @IBOutlet weak var unreadCounterBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        unreadCounterBackgroundView.layer.cornerRadius = unreadCounterBackgroundView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(recent:RecentChat){
        
        userNameLabel.text = recent.receiverName
        userNameLabel.adjustsFontSizeToFitWidth = true
        userNameLabel.minimumScaleFactor = 0.9
        
        lastMessageLabel.text = recent.lastMessage
        lastMessageLabel.adjustsFontSizeToFitWidth = true
        lastMessageLabel.numberOfLines = 2
        lastMessageLabel.minimumScaleFactor = 0.9
        
        setAvatar(avatarLink: recent.avatarLink)
        dateLabel.text = timeElapsed(recent.date ?? Date())
        dateLabel.adjustsFontSizeToFitWidth = true
        
        
        if recent.unreadCounter != 0{
            unreadCounterLabel.text = "\(recent.unreadCounter)"
            unreadCounterBackgroundView.isHidden = false
        }else{
            unreadCounterBackgroundView.isHidden = true
        }
    }
    
    private func setAvatar(avatarLink:String){
        
        if avatarLink != ""{
            FileStorage.downloadImage(imageUrl: avatarLink) { image in
                self.avatarImageView.image = image?.circleMasked
            }
        }else{
            self.avatarImageView.image = UIImage(named: "avatar")?.circleMasked
        }
        
    }
}
