//
//  UserTableViewCell.swift
//  SNBMessanger
//
//  Created by Syamala on 09/07/22.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(user:User){
        userNameLabel.text = user.userName
        statusLabel.text = user.status
        setAvatar(avatarLink: user.avatarLink)
    }
    
    private func setAvatar(avatarLink:String){
        
        if avatarLink != ""{
            FileStorage.downloadImage(imageUrl: avatarLink) { avatarImage in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        }else{
            self.avatarImageView.image = UIImage(named: "avatar")?.circleMasked
        }
    }
}
