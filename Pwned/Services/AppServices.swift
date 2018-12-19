//
//  AppServices.swift
//  Pwned
//
//  Created by Kevin on 11/30/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

struct AppServices: HasReduxStore, HasPwnedService,
    HasSettingsService, HasSearchHistoryService, HasImageCacheService {
    let mainStore: ReduxStore
    let pwnedService: PwnedServiceProtocol
    let settingsService: SettingsServiceProtocol
    let searchHistoryService: SearchHistoryService
    let imageService: ImageCacheService
}
