//
//  PasteDetailViewModel.swift
//  Pwned
//
//  Created by Kevin on 11/10/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

class PasteDetailViewModel: ViewModel {
    private static var countFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter
    }
    private let paste: Paste
    private let disposeBag = DisposeBag()

    // MARK: - Rx Inputs
    /// Trigger the visitURL step
    var visitURLTrigger = PublishSubject<Void>()

    var title: String {
        return paste.titleOrDefault
    }

    var formattedDate: String? {
        return paste.formattedDate
    }

    var emailCount: String {
        return PasteDetailViewModel.countFormatter
            .string(from: NSNumber(value: paste.emailCount)) ?? ""
    }

    var source: String {
        return paste.source
    }

    var url: String? {
        let pasteService = PasteService(rawValue: paste.source)
        guard let service = pasteService else { return nil }
        let url = service.getURL(for: paste.identifier)
        return url
    }

    init(paste: Paste) {
        self.paste = paste

        visitURLTrigger
            .subscribe(onNext: { [weak self] in
                self?.visitURL()
            })
            .disposed(by: disposeBag)
    }
}

extension PasteDetailViewModel: Stepper {
    public func visitURL() {
        if let urlString = self.url, let url = URL(string: urlString) {
            self.step.accept(AppStep.visitURL(url))
        }
    }
}
