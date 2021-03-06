//
//  BusinessCell.swift
//  Yelp
//
//  Created by Nicholas Miller on 1/31/16.
//  Copyright © 2016 Nicholas Miller. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    var business: Business! {
        didSet {
            if (business.imageURL != nil) {
                thumbImageView.setImageWithURL(business.imageURL!)
            }
            if (business.name != nil) {
                nameLabel.text = business.name!
            }
            if (business.distance != nil) {
                distanceLabel.text = business.distance
            }
            if (business.ratingImageURL != nil) {
                ratingImageView.setImageWithURL(business.ratingImageURL!)
            }
            if (business.reviewCount != nil) {
                reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
            }
            if (business.address != nil) {
                addressLabel.text = business.address
            }
            if (business.categories != nil) {
                categoriesLabel.text = business.categories
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
        
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
