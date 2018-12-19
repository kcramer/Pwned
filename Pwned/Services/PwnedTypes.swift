//
//  PwnedTypes.swift
//  Pwned
//
//  Created by Kevin on 7/11/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import HIBPKit

typealias PasswordResult = HIBPService.PasswordResult

enum BreachResult: Equatable {
    case success([Breach])
    case notFound
    case failure(ServiceError)

    init(_ result: HIBPService.BreachResult) {
        switch result {
        case .success(let breaches):
            self = .success(breaches)
        case .failure(let error):
            switch error {
            case .notFound:
                self = .notFound
            default:
                self = .failure(error)
            }
        }
    }

    var value: [Breach]? {
        guard case .success(let values) = self else { return nil }
        return values
    }

    var error: ServiceError? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}

enum PasteResult: Equatable {
    case success([Paste])
    case notFound
    case failure(ServiceError)

    init(_ result: HIBPService.PasteResult) {
        switch result {
        case .success(let pastes):
            self = .success(pastes)
        case .failure(let error):
            switch error {
            case .notFound:
                self = .notFound
            default:
                self = .failure(error)
            }
        }
    }

    var value: [Paste]? {
        guard case .success(let values) = self else { return nil }
        return values
    }

    var error: ServiceError? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}

enum AccountListResult: Equatable {
    case success([Breach]?, [Paste]?)
    case notFound
    case failure([ServiceError])

    /**
     Combine two results to produce a new result.  At least one result
     must be non-nil.  As long as one is found, the result is found.
     Otherwise, if at least one is not found, return notFound.  If both
     have errors, return the errors.
     - parameter: The breach if available.
     - parameter: The paste if available.
     */
    init?(_ breach: BreachResult?, _ paste: PasteResult?) {
        switch (breach, paste) {
        case (.success?, _), (_, .success?):
            self = .success(breach?.value, paste?.value)
        case (.notFound?, .notFound?), (.failure?, .notFound?), (.notFound?, .failure?):
            self = .notFound
        case (.failure?, .failure?):
            self = .failure([breach?.error, paste?.error].compactMap { $0 })
        default:
            return nil
        }
    }

    var breaches: [Breach]? {
        guard case .success(let breaches, _) = self else { return nil }
        return breaches
    }

    var pastes: [Paste]? {
        guard case .success(_, let pastes) = self else { return nil }
        return pastes
    }

    var errors: [ServiceError]? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}

enum AccountState: Equatable {
    case initialState
    case searching(String)
    case result(AccountListResult)
}

enum PasswordState: Equatable, CustomStringConvertible {
    case initialState
    case searching(String)
    case result(PasswordResult)

    var description: String {
        switch self {
        case .initialState:
            return "initialState"
        case .searching(let password):
            return "searching(\"\(password.isEmpty ? "" : "...")\")"
        case .result(let result):
            return "result(\(result))"
        }
    }
}
