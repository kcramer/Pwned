//
//  HIBPService.swift
//  Pwned
//
//  Created by Kevin on 7/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import HIBPKit

public typealias Breach = HIBPKit.Breach
public typealias Paste = HIBPKit.Paste
public typealias PasteService = HIBPKit.PasteService
public typealias ServiceRequest = HIBPKit.ServiceRequest
public typealias ServiceError = HIBPKit.ServiceError

protocol HasPwnedService {
    var pwnedService: PwnedServiceProtocol { get }
}

protocol PwnedServiceProtocol: class {
    init(userAgent: String)

    static func isEmail(_ email: String) -> Bool

    @discardableResult
    func passwordByRange(password: String,
                         completion: @escaping (PasswordResult) -> Void)
        -> ServiceRequest?

    @discardableResult
    func breaches(for account: String, unverified: Bool,
                  completion: @escaping (BreachResult) -> Void)
        -> ServiceRequest?

    @discardableResult
    func pastes(for account: String,
                completion: @escaping (PasteResult) -> Void)
        -> ServiceRequest?
}

class PwnedService: PwnedServiceProtocol {
    let service: HIBPService

    required init(userAgent: String) {
        service = HIBPService(userAgent: userAgent)
    }

    static func isEmail(_ email: String) -> Bool {
        return HIBPService.isEmail(email)
    }

    public static var iso8601Custom: JSONDecoder.DateDecodingStrategy {
        return HIBPService.iso8601Custom
    }

    @discardableResult
    func passwordByRange(password: String,
                         completion: @escaping (PasswordResult) -> Void)
        -> ServiceRequest? {
        return service.passwordByRange(password: password) { result in
            completion(result)
        }
    }

    @discardableResult
    func breaches(for account: String, unverified: Bool = true,
                  completion: @escaping (BreachResult) -> Void)
        -> ServiceRequest? {
        return service.breaches(for: account, unverified: unverified) { result in
            completion(BreachResult(result))
        }
    }

    @discardableResult
    func pastes(for account: String,
                completion: @escaping (PasteResult) -> Void)
        -> ServiceRequest? {
        return service.pastes(for: account) { result in
            completion(PasteResult(result))
        }
    }
}
