//
//  MovieCollectionViewCell.swift
//  MoviesApp
//
//  Created by Le Huynh Anh Tien on 7/11/16.
//  Copyright © 2016 Tien Le. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
  
    @IBOutlet weak var imagePoster: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
   

}
