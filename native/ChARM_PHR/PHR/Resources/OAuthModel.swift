//
//  OAuthModel.swift
//  phr
//
//  Created by Sankar Saravanan on 23/04/20.
//  Copyright © 2020 Dhanuprasanya P. All rights reserved.
//

import Foundation

//let scopes =  "charmphr.patient.fullaccess.ALL,charmphr.careteam.ALL,charmphr.user.setting.ALL,charmphr.defaults.CREATE,charmphr.fhir.patient.ALL"

class ApplicationDetails : NSObject {
    
    static var urlScheme: String {
        guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]],
              let schemes = urlTypes.first?["CFBundleURLSchemes"] as? [String],
              let scheme = schemes.first else {
            return ""
        }
        return scheme
    }
    
    /// mPHR-Secrets.plist (gitignored). Holds the Zoho `Client_Id` and the CHIS/Auth0 `Auth0_*` settings.
    private static let plist: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "mPHR-Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else { return [:] }
        return dict
    }()
    private static func secret(_ key: String) -> String { plist[key] as? String ?? "" }
    private static func secretArray(_ key: String) -> [String] { plist[key] as? [String] ?? [] }

    //MARK: - CharmAuthKit (CHIS / Auth0) sign-in settings
    // Read from mPHR-Secrets.plist. If any is missing or wrong, CharmAuthSession refuses to start
    // and logs every setting to fix.
    
    static var issuer: String { secret("Auth0_Issuer") }
    static var clientId: String { secret("Auth0_ClientId") }
    static var audience: String? { let a = secret("Auth0_Audience"); return a.isEmpty ? nil : a }
    // The API's permission scopes (e.g. "patient.fullaccess.read"), appended by the SDK after its
    // own default scopes (openid profile email offline_access).
    static var additionalScopes: [String] { secretArray("Auth0_Scopes") }
    // CHIS's branded /chis/login pass-through: when set, sign-in opens this URL (with the same
    // params CharmAuthKit would've sent Auth0's /authorize) instead of going to Auth0 directly.
    // Left empty until CHIS's endpoint is live - nil then means "Auth0 /authorize as today".
    static var signInEntryUrl: String? { let u = secret("Auth0_SignInEntryUrl"); return u.isEmpty ? nil : u }
    // The only origins (https://host[:port]) the SDK sends the access token to: this environment's
    // EHR, i.e. the origin of the SERVER build setting. Empty: every API call is refused.
    static var apiOrigins: [String] { secretArray("Auth0_ApiOrigins") }
    static var redirectURI: String { "\(urlScheme):/oauth2/callback" }
}
