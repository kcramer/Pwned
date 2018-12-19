//
//  ImageCacheService.swift
//  Pwned
//
//  Created by Kevin on 11/30/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import ComposableCacheKit

typealias ImageCacheService = SimpleCache<String, UIImage>

protocol HasImageCacheService {
    var imageService: SimpleCache<String, UIImage> { get }
}
