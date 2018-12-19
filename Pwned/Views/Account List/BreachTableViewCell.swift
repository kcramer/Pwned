//
//  BreachTableViewCell.swift
//  Pwned
//
//  Created by Kevin on 7/7/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit

class BreachTableViewCell: UITableViewCell {
    var breach: Breach?
    var imageService: ImageCacheService?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!

    func configure(breach: Breach, imageService: ImageCacheService) {
        self.breach = breach
        self.imageService = imageService
        titleLabel.text = breach.title
        dateLabel.text = breach.formattedDate
        logoImageView.image = nil
        guard let path = breach.logoPath else { return }
        imageService.get(key: path).then({ image in
            DispatchQueue.main.async {
                // Only update the image if the cell has not changed.
                guard self.breach?.logoPath == path else { return }
                self.logoImageView.image = image
            }
        })
    }
}
