//
//  OnboardingTemplateViewController.swift
//  Pwned
//
//  Created by Kevin on 10/29/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import Reusable

class OnboardingTemplateViewController: UIViewController, StoryboardBased {
    var image: UIImage? {
        didSet {
            update()
        }
    }

    var text: String? {
        didSet {
            update()
        }
    }

    @IBOutlet var topImageView: UIImageView!
    @IBOutlet var textLabel: UILabel!

    private func update() {
        if let image = image {
            topImageView?.image = image
        }
        if let text = text {
            textLabel?.text = text
        }
    }

    override func viewDidLoad() {
        update()
    }
}
