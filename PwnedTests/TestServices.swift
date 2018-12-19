//
//  MockServices.swift
//  PwnedTests
//
//  Created by Kevin on 11/12/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit
import ComposableCacheKit
@testable import Pwned

/// Creates the app services using test doubles as needed.
func createServices() -> AppServices {
    let store = ReduxStore()
    let pwnedService = StubPwnedService()
    let settingsService = FakeSettingsService()
    let searchHistoryService = SearchHistoryService(
        store: store, settingsService: settingsService)
    let imageService = SimpleCache(from: MemoryCache<UIImage>(subsystem: "Pwned-Testing"))
    return AppServices(mainStore: store,
                       pwnedService: pwnedService,
                       settingsService: settingsService,
                       searchHistoryService: searchHistoryService,
                       imageService: imageService)
}

/// A fake in-memory setting service.
class FakeSettingsService: SettingsServiceProtocol {
    var onboardingCompleted: Bool = false
    var accountHistory: [String] = []
    var resetOnboarding: Bool = false
    var clearImageCache: Bool = false
}

/// Stub version of the PwnedService that just returns some
/// pre-defined responses.
class StubPwnedService: PwnedServiceProtocol {
    static func decode<T: Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = PwnedService.iso8601Custom
        let result = try decoder.decode(T.self, from: data)
        return result
    }

    static func decode<T: Decodable>(string: String) throws -> T {
        let data = string.data(using: .utf8) ?? Data()
        return try StubPwnedService.decode(data: data)
    }

    required init(userAgent: String) {
    }

    convenience init() {
        self.init(userAgent: "Pwnd-for-iOS")
    }

    static func isEmail(_ email: String) -> Bool {
        return PwnedService.isEmail(email)
    }

    @discardableResult
    func passwordByRange(password: String,
                         completion: @escaping (PasswordResult) -> Void)
        -> ServiceRequest? {
        switch password {
        case "password":
            completion(.success(3000000))
        case "error":
            completion(.failure(.offline("Offline")))
        default:
            completion(.success(0))
        }
        return nil
    }

    func breaches(for account: String, unverified: Bool = true,
                  completion: @escaping (BreachResult) -> Void)
        -> ServiceRequest? {

        switch account {
        case "john.doe@example.com":
            guard let breaches: [Breach] =
                try? StubPwnedService.decode(string: johnDoeBreaches) else {
                completion(.failure(.parseError("Could not parse string!")))
                return nil
            }
            completion(.success(breaches))
        case "john.doe":
            completion(.notFound)
        case "noone@nowhere.com":
            completion(.notFound)
        case "error", "error@nowhere.com":
            completion(.failure(.offline("Offline")))
        default:
            completion(.notFound)
        }
        return nil
    }

    func pastes(for account: String,
                completion: @escaping (PasteResult) -> Void)
        -> ServiceRequest? {

        switch account {
        case "john.doe@example.com":
            guard let pastes: [Paste] =
                try? StubPwnedService.decode(string: johnDoePastes) else {
                completion(.failure(.parseError("Could not parse string!")))
                return nil
            }
            completion(.success(pastes))
        case "john.doe":
            completion(.notFound)
        case "noone@nowhere.com":
            completion(.notFound)
        case "error", "error@nowhere.com":
            completion(.failure(.offline("Offline")))
        default:
            completion(.notFound)
        }
        return nil
    }
}

let johnDoeBreachParsed: [Breach] =
    (try? StubPwnedService.decode(string: johnDoeBreaches)) ?? []
let johnDoePastesParsed: [Paste] =
    (try? StubPwnedService.decode(string: johnDoePastes)) ?? []

// swiftlint:disable line_length
let johnDoeBreaches =
"""
[{"Name":"Adobe","Title":"Adobe","Domain":"adobe.com","BreachDate":"2013-10-04","AddedDate":"2013-12-04T00:00:00Z","ModifiedDate":"2013-12-04T00:00:00Z","PwnCount":152445165,"Description":"In October 2013, 153 million Adobe accounts were breached with each containing an internal ID, username, email, <em>encrypted</em> password and a password hint in plain text. The password cryptography was poorly done and <a href=\\"http://stricture-group.com/files/adobe-top100.txt\\" target=\\"_blank\\" rel=\\"noopener\\">many were quickly resolved back to plain text</a>. The unencrypted hints also <a href=\\"http://www.troyhunt.com/2013/11/adobe-credentials-and-serious.html\\" target=\\"_blank\\" rel=\\"noopener\\">disclosed much about the passwords</a> adding further to the risk that hundreds of millions of Adobe customers already faced.","LogoType":"svg","DataClasses":["Email addresses","Password hints","Passwords","Usernames"],"IsVerified":true,"IsFabricated":false,"IsSensitive":false,"IsRetired":false,"IsSpamList":false},{"Name":"Apollo","Title":"Apollo","Domain":"apollo.io","BreachDate":"2018-07-23","AddedDate":"2018-10-05T19:14:11Z","ModifiedDate":"2018-10-23T04:01:48Z","PwnCount":125929660,"Description":"In July 2018, the sales engagement startup <a href=\\"https://www.wired.com/story/apollo-breach-linkedin-salesforce-data/\\" target=\\"_blank\\" rel=\\"noopener\\">Apollo left a database containing billions of data points publicly exposed without a password</a>. The data was discovered by security researcher <a href=\\"http://www.vinnytroia.com/\\" target=\\"_blank\\" rel=\\"noopener\\">Vinny Troia</a> who subsequently sent a subset of the data containing 126 million unique email addresses to Have I Been Pwned. The data left exposed by Apollo was used in their &quot;revenue acceleration platform&quot; and included personal information such as names and email addresses as well as professional information including places of employment, the roles people hold and where they're located. Apollo stressed that the exposed data did not include sensitive information such as passwords, social security numbers or financial data. <a href=\\"https://www.apollo.io/contact\\" target=\\"_blank\\" rel=\\"noopener\\">The Apollo website has a contact form</a> for those looking to get in touch with the organisation.","LogoType":"svg","DataClasses":["Email addresses","Employers","Geographic locations","Job titles","Names","Phone numbers","Salutations","Social media profiles"],"IsVerified":true,"IsFabricated":false,"IsSensitive":false,"IsRetired":false,"IsSpamList":false},{"Name":"CouponMomAndArmorGames","Title":"Coupon Mom / Armor Games","Domain":"","BreachDate":"2014-02-08","AddedDate":"2017-11-09T23:46:52Z","ModifiedDate":"2017-11-09T23:46:52Z","PwnCount":11010525,"Description":"In 2014, a file allegedly containing data hacked from <a href=\\"https://www.couponmom.com\\" target=\\"_blank\\" rel=\\"noopener\\">Coupon Mom</a> was created and included 11 million email addresses and plain text passwords. On further investigation, the file was also found to contain data indicating it had been sourced from <a href=\\"https://armorgames.com\\" target=\\"_blank\\" rel=\\"noopener\\">Armor Games</a>. Subsequent verification with HIBP subscribers confirmed the passwords had previously been used and many subscribers had used either Coupon Mom or Armor Games in the past. On disclosure to both organisations, each found that the data did not represent their entire customer base and possibly includes records from other sources with common subscribers. The breach has subsequently been flagged as &quot;unverified&quot; as the source cannot be emphatically proven.","LogoType":"png","DataClasses":["Email addresses","Passwords"],"IsVerified":false,"IsFabricated":false,"IsSensitive":false,"IsRetired":false,"IsSpamList":false},{"Name":"Disqus","Title":"Disqus","Domain":"disqus.com","BreachDate":"2012-07-01","AddedDate":"2017-10-06T23:03:51Z","ModifiedDate":"2017-10-06T23:03:51Z","PwnCount":17551044,"Description":"In October 2017, the blog commenting service <a href=\\"https://blog.disqus.com/security-alert-user-info-breach\\" target=\\"_blank\\" rel=\\"noopener\\">Disqus announced they'd suffered a data breach</a>. The breach dated back to July 2012 but wasn't identified until years later when the data finally surfaced. The breach contained over 17.5 million unique email addresses and usernames. Users who created logins on Disqus had salted SHA1 hashes of passwords whilst users who logged in via social providers only had references to those accounts.","LogoType":"svg","DataClasses":["Email addresses","Passwords","Usernames"],"IsVerified":true,"IsFabricated":false,"IsSensitive":false,"IsRetired":false,"IsSpamList":false},{"Name":"Dropbox","Title":"Dropbox","Domain":"dropbox.com","BreachDate":"2012-07-01","AddedDate":"2016-08-31T00:19:19Z","ModifiedDate":"2016-08-31T00:19:19Z","PwnCount":68648009,"Description":"In mid-2012, Dropbox suffered a data breach which exposed the stored credentials of tens of millions of their customers. In August 2016, <a href=\\"https://motherboard.vice.com/read/dropbox-forces-password-resets-after-user-credentials-exposed\\" target=\\"_blank\\" rel=\\"noopener\\">they forced password resets for customers they believed may be at risk</a>. A large volume of data totalling over 68 million records <a href=\\"https://motherboard.vice.com/read/hackers-stole-over-60-million-dropbox-accounts\\" target=\\"_blank\\" rel=\\"noopener\\">was subsequently traded online</a> and included email addresses and salted hashes of passwords (half of them SHA1, half of them bcrypt).","LogoType":"svg","DataClasses":["Email addresses","Passwords"],"IsVerified":true,"IsFabricated":false,"IsSensitive":false,"IsRetired":false,"IsSpamList":false},{"Name":"Edmodo","Title":"Edmodo","Domain":"edmodo.com","BreachDate":"2017-05-11","AddedDate":"2017-06-01T05:59:24Z","ModifiedDate":"2017-06-01T05:59:24Z","PwnCount":43423561,"Description":"In May 2017, the education platform <a href=\\"https://motherboard.vice.com/en_us/article/hacker-steals-millions-of-user-account-details-from-education-platform-edmodo\\" target=\\"_blank\\" rel=\\"noopener\\">Edmodo was hacked</a> resulting in the exposure of 77 million records comprised of over 43 million unique customer email addresses. The data was consequently published to a popular hacking forum and made freely available. The records in the breach included usernames, email addresses and bcrypt hashes of passwords.","LogoType":"svg","DataClasses":["Email addresses","Passwords","Usernames"],"IsVerified":true,"IsFabricated":false,"IsSensitive":false,"IsRetired":false,"IsSpamList":false},{"Name":"Evony","Title":"Evony","Domain":"evony.com","BreachDate":"2016-06-01","AddedDate":"2017-03-25T23:43:45Z","ModifiedDate":"2017-03-25T23:43:45Z","PwnCount":29396116,"Description":"In June 2016, the online multiplayer game <a href=\\"http://securityaffairs.co/wordpress/52260/data-breach/evony-data-breach.html\\" target=\\"_blank\\" rel=\\"noopener\\">Evony was hacked</a> and over 29 million unique accounts were exposed. The attack led to the exposure of usernames, email and IP addresses and MD5 hashes of passwords (without salt).","LogoType":"png","DataClasses":["Email addresses","IP addresses","Passwords","Usernames"],"IsVerified":true,"IsFabricated":false,"IsSensitive":false,"IsRetired":false,"IsSpamList":false},{"Name":"Leet","Title":"Leet","Domain":"leet.cc","BreachDate":"2016-09-10","AddedDate":"2016-09-30T22:00:48Z","ModifiedDate":"2016-09-30T22:00:48Z","PwnCount":5081689,"Description":"In August 2016, the service for creating and running Pocket Minecraft edition servers known as <a href=\\"http://news.softpedia.com/news/data-for-6-million-minecraft-gamers-stolen-from-leet-cc-servers-507445.shtml\\" target=\\"_blank\\" rel=\\"noopener\\">Leet was reported as having suffered a data breach that impacted 6 million subscribers</a>. The incident reported by Softpedia had allegedly taken place earlier in the year, although the data set sent to HIBP was dated as recently as early September but contained only 2 million subscribers. The data included usernames, email and IP addresses and SHA512 hashes. A further 3 million accounts were obtained and added to HIBP several days after the initial data was loaded bringing the total to over 5 million.","LogoType":"png","DataClasses":["Email addresses","IP addresses","Passwords","Usernames","Website activity"],"IsVerified":true,"IsFabricated":false,"IsSensitive":false,"IsRetired":false,"IsSpamList":false},{"Name":"ModernBusinessSolutions","Title":"Modern Business Solutions","Domain":"modbsolutions.com","BreachDate":"2016-10-08","AddedDate":"2016-10-12T09:09:11Z","ModifiedDate":"2016-10-12T09:09:11Z","PwnCount":58843488,"Description":"In October 2016, a large Mongo DB file containing tens of millions of accounts <a href=\\"https://twitter.com/0x2Taylor/status/784544208879292417\\" target=\\"_blank\\" rel=\\"noopener\\">was shared publicly on Twitter</a> (the file has since been removed). The database contained over 58M unique email addresses along with IP addresses, names, home addresses, genders, job titles, dates of birth and phone numbers. The data was subsequently <a href=\\"http://news.softpedia.com/news/hacker-steals-58-million-user-records-from-data-storage-provider-509190.shtml\\" target=\\"_blank\\" rel=\\"noopener\\">attributed to &quot;Modern Business Solutions&quot;</a>, a company that provides data storage and database hosting solutions. They've yet to acknowledge the incident or explain how they came to be in possession of the data.","LogoType":"png","DataClasses":["Dates of birth","Email addresses","Genders","IP addresses","Job titles","Names","Phone numbers","Physical addresses"],"IsVerified":true,"IsFabricated":false,"IsSensitive":false,"IsRetired":false,"IsSpamList":false},{"Name":"OnlinerSpambot","Title":"Onliner Spambot","Domain":"","BreachDate":"2017-08-28","AddedDate":"2017-08-29T19:25:56Z","ModifiedDate":"2017-08-29T19:25:56Z","PwnCount":711477622,"Description":"In August 2017, a spambot by the name of <a href=\\"https://benkowlab.blogspot.com.au/2017/08/from-onliner-spambot-to-millions-of.html\\" target=\\"_blank\\" rel=\\"noopener\\">Onliner Spambot was identified by security researcher Benkow moʞuƎq</a>. The malicious software contained a server-based component located on an IP address in the Netherlands which exposed a large number of files containing personal information. In total, there were 711 million unique email addresses, many of which were also accompanied by corresponding passwords. A full write-up on what data was found is in the blog post titled <a href=\\"https://www.troyhunt.com/inside-the-massive-711-million-record-onliner-spambot-dump\\" target=\\"_blank\\" rel=\\"noopener\\">Inside the Massive 711 Million Record Onliner Spambot Dump</a>.","LogoType":"png","DataClasses":["Email addresses","Passwords"],"IsVerified":true,"IsFabricated":false,"IsSensitive":false,"IsRetired":false,"IsSpamList":true},{"Name":"RiverCityMedia","Title":"River City Media Spam List","Domain":"rivercitymediaonline.com","BreachDate":"2017-01-01","AddedDate":"2017-03-08T23:49:53Z","ModifiedDate":"2017-03-08T23:49:53Z","PwnCount":393430309,"Description":"In January 2017, <a href=\\"https://mackeeper.com/blog/post/339-spammergate-the-fall-of-an-empire\\" target=\\"_blank\\" rel=\\"noopener\\">a massive trove of data from River City Media was found exposed online</a>. The data was found to contain almost 1.4 billion records including email and IP addresses, names and physical addresses, all of which was used as part of an enormous spam operation. Once de-duplicated, there were 393 million unique email addresses within the exposed data.","LogoType":"png","DataClasses":["Email addresses","IP addresses","Names","Physical addresses"],"IsVerified":true,"IsFabricated":false,"IsSensitive":false,"IsRetired":false,"IsSpamList":true}]
"""

let johnDoePastes =
"""
[{"Id":"EgEQWD9X","Source":"Pastebin","Title":null,"Date":"2014-08-07T11:08:00Z","EmailCount":2232},{"Id":"tJmdW6sp","Source":"Pastebin","Title":null,"Date":"2014-08-29T23:08:00Z","EmailCount":10124},{"Id":"ySsxn7BK","Source":"Pastebin","Title":"PH1K3 EGYPT GOV LEAK","Date":"2014-09-16T16:09:00Z","EmailCount":1218},{"Id":"TSYYzd3d","Source":"Pastebin","Title":null,"Date":"2014-11-02T14:11:00Z","EmailCount":7260},{"Id":"D15861DF","Source":"Pastebin","Title":"Egypt gov stuff","Date":"2015-05-01T11:13:47Z","EmailCount":1218},{"Id":"uMq1W2mx","Source":"Pastebin","Title":"npm-debug.log","Date":"2015-05-10T23:57:41Z","EmailCount":40},{"Id":"nwTYjcq8","Source":"Pastebin","Title":"EMAIL PACK","Date":"2015-09-13T22:18:12Z","EmailCount":5031},{"Id":"9Q6K7WAJ","Source":"Pastebin","Title":null,"Date":"2015-10-13T21:27:09Z","EmailCount":1218},{"Id":"y0AJ6w5C","Source":"Pastebin","Title":"jancok","Date":"2016-06-07T16:21:54Z","EmailCount":706},{"Id":"MAWjwejS","Source":"Pastebin","Title":null,"Date":"2016-07-07T03:24:30Z","EmailCount":739},{"Id":"rL214a2T","Source":"Pastebin","Title":null,"Date":"2016-11-05T11:45:06Z","EmailCount":15},{"Id":"BVY9QMLw","Source":"Pastebin","Title":null,"Date":"2016-12-02T18:58:53Z","EmailCount":1181},{"Id":"u29CrJwd","Source":"Pastebin","Title":"IP","Date":"2017-08-23T17:36:56Z","EmailCount":3},{"Id":"Ex7NMMwV","Source":"Pastebin","Title":null,"Date":"2017-12-05T12:28:12Z","EmailCount":9997},{"Id":"eEbyVS1s","Source":"Pastebin","Title":null,"Date":"2018-04-23T16:10:59Z","EmailCount":286}]
"""
