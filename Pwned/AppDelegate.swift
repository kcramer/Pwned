//
//  AppDelegate.swift
//  Pwned
//
//  Created by Kevin on 6/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow
import os.log
import ComposableCacheKit

@UIApplicationMain
class AppDelegate: UIResponder {
    static let appID = Bundle.main.bundleIdentifier ?? "net.kevincramer.Pwned"
    static let logger = OSLog(subsystem: AppDelegate.appID,
                              category: "main")

    var window: UIWindow?
    let bag = DisposeBag()
    let coordinator = Coordinator()
    let hibpService = PwnedService(userAgent: "Pwned-iOS-App")
    let mainStore = ReduxStore()
    lazy var settingsService = {
        return SettingsService(store: mainStore)
    }()
    lazy var searchHistoryService = {
        return SearchHistoryService(store: mainStore,
                                    settingsService: settingsService)
    }()
    lazy var memoryCache = {
        return MemoryCache<UIImage>(subsystem: AppDelegate.appID)
    }()
    lazy var diskCache = {
        return DiskCache(path: "\(AppDelegate.appID)/Pwned/Images/",
                         logSubsystem: AppDelegate.appID,
                         limit: 30_000_000)
    }()
    lazy var networkCache = {
        return NetworkCache(subsystem: AppDelegate.appID)
    }()
    lazy var imageCacheService: ImageCacheService = {
        let backingCache = diskCache
            .compose(with: networkCache)
            .pooled()
            .mappingValues(using: BidirectionalMappers.dataToImageMapper)
        return memoryCache.compose(with: backingCache)
    }()
    var appFlow: AppFlow!
    lazy var appServices = {
        return AppServices(mainStore: self.mainStore,
                           pwnedService: self.hibpService,
                           settingsService: self.settingsService,
                           searchHistoryService: self.searchHistoryService,
                           imageService: self.imageCacheService)
    }()
}

extension AppDelegate: UIApplicationDelegate {
    private func applyTheme() {
        let almostBlack = UIColor(white: 0.1, alpha: 1.0)
        let iron = UIColor(white: 0.3, alpha: 1)
        let navBar = UINavigationBar.appearance()
        navBar.barTintColor = almostBlack
        navBar.tintColor = UIColor.white
        navBar.barStyle = .black
        let tabBar = UITabBar.appearance()
        tabBar.barTintColor = almostBlack
        tabBar.tintColor = UIColor.white
        let tableView = UITableView.appearance()
        tableView.backgroundColor = iron
        let tableViewCell = UITableViewCell.appearance()
        tableViewCell.backgroundColor = .clear
        let cellLabel = UILabel.appearance(
            whenContainedInInstancesOf: [UITableViewCell.self])
        cellLabel.textColor = .white
        let labelInTableViewHeader = UILabel.appearance(
            whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
        labelInTableViewHeader.textColor = .white
    }

    func clearImageCacheIfSet() {
        if settingsService.clearImageCache {
            settingsService.clearImageCache = false
            os_log("Clearing Icon Cache", log: AppDelegate.logger, type: .info)
            _ = imageCacheService.clear()
        }
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        guard let window = self.window else { return false }

        applyTheme()
        clearImageCacheIfSet()

        coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            os_log("did navigate to flow=%{public}@ and step=%{public}@",
                   log: AppDelegate.logger,
                   type: .debug,
                   String(describing: flow),
                   String(describing: step))
        }).disposed(by: self.bag)

        self.appFlow = AppFlow(withWindow: window, andServices: self.appServices)
        coordinator.coordinate(flow: self.appFlow,
                               withStepper: AppStepper(withServices: self.appServices))
        return true
    }
}
