//
//  AuthenticationUtil.swift
//  phr
//
//  Created by Prathiba Murugesan on 09/09/26.
//  Copyright © 2026 Prathiba Murugesan. All rights reserved.
//

import Foundation
import UIKit
import Combine
import CharmAuthKit

//This is the only place that should talk to the CharmAuthKit SDK (native/ChARM_PHR/charm-mobile-auth-sdk submodule) directly.
//Every other file must go through these wrapper functions instead of calling CharmAuthSession on its own.
struct AuthenticationUtil {

    /// Holds the one CharmAuthSession for the app (the SDK is main-actor isolated). `session` is nil
    /// only when the build's CHIS settings are wrong (see `ApplicationDetails.chis*`); `initAuth`
    /// logs the SDK's message listing what to fix.
    @MainActor private enum Holder {
        static var session: CharmAuthSession?
        static var stateObserver: AnyCancellable?
    }

    /// `CharmAuthSession.restore()` is async, but the app decides login vs. lock screen synchronously at
    /// launch. This mirrors the SDK's signed-in state so `isUserSignedIn()` can answer right away.
    private static let signedInKey = "charmAuthKit.isSignedIn"

    //MARK: - setup

    @MainActor static func initAuth() -> Void {
        guard Holder.session == nil else { return }
        do {
            let auth = try CharmAuthSession(
                issuer: ApplicationDetails.issuer,
                clientId: ApplicationDetails.clientId,
                redirectUri: ApplicationDetails.redirectURI,
                audience: ApplicationDetails.audience,
                additionalScopes: ApplicationDetails.additionalScopes,
                apiOrigins: ApplicationDetails.apiOrigins
            )
            Holder.session = auth
            Holder.stateObserver = auth.$state.sink { state in
                switch state {
                case .signedIn:
                    setSignedInFlag(true)
                case .signedOut(let reason, let sessionEnded):
                    let wasSignedIn = isUserSignedIn()
                    setSignedInFlag(false)
                    // The server ended the session in the background (revoked, user blocked, expired).
                    if sessionEnded && wasSignedIn {
                        debugPrintLog("CharmAuth session ended: \(reason ?? "")")
                        AuthManager.logoutUser(isInvalidOAuth: true)
                    }
                case .unknown:
                    break
                }
            }
            Task { _ = try? await auth.restore() }
        } catch {
            debugPrintLog("CharmAuth is misconfigured: \(error)")
        }
    }

    static func getUserAgent() -> String {
        let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        let systemVersion = UIDevice.current.systemVersion

        return "AppName:Charm mPHR iOS; Version:\(appVersion); OS Version:\(systemVersion)"
    }

    //MARK: - error helper

    /// Unwraps a CharmAuthKit SDK error back to its typed `CharmAuthError`, if that's what it is.
    static func charmAuthError(from error: Error?) -> CharmAuthError? {
        error as? CharmAuthError
    }

    //MARK: - session state

    static func isUserSignedIn() -> Bool {
        UserDefaults.standard.bool(forKey: signedInKey)
    }

    private static func setSignedInFlag(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: signedInKey)
    }

    /// Clears the local sign-in. The SDK already discards a previous install's Keychain sign-in on a
    /// fresh install; this also covers the app's own "first launch" / migration resets.
    static func clearDetailsForFirstLaunch() {
        setSignedInFlag(false)
        Task { @MainActor in await Holder.session?.signOut() }
    }

    //MARK: - URL handling

    static func handleURL(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        // CharmAuthKit signs in via ASWebAuthenticationSession, which receives its own redirect
        // callback - the SDK never needs the host app to hand it the redirect URL. This just
        // reports whether the URL was ours to begin with.
        return url.scheme == ApplicationDetails.urlScheme
    }

    //MARK: - access token

    static func getToken(token: @escaping (String, Error?) -> Void){

        getOAuthToken { oAuthToken, error in
            if error == nil {
                token(oAuthToken, nil)
            }
            else{
                token("", error)
            }
        }
    }

    static private func getOAuthToken(oAuthToken: @escaping (String, Error?) -> Void) {
        Task { @MainActor in
            guard let session = Holder.session else {
                oAuthToken("", CharmAuthError.notSignedIn)
                return
            }
            do {
                let accessToken = try await session.accessToken()
                oAuthToken(accessToken, nil)
            } catch {
                debugPrintLog("error in get token : \(error)")
                switch charmAuthError(from: error) {
                case .sessionEnded, .notSignedIn:
                    AuthManager.logoutUser(isInvalidOAuth: true)
                default:
                    oAuthToken("", error)
                }
            }
        }
    }

    //MARK: - sign in / scopes

    /// Completion gets the signed-in user's id (`sub`). A user-cancelled sign-in completes with
    /// `(nil, nil)`, which callers treat as "nothing to report".
    static func presentSignIn(completion: @escaping (String?, Error?) -> Void) {
        Task { @MainActor in
            guard let session = Holder.session else {
                completion(nil, CharmAuthError.misconfigured("CharmAuth was not initialised"))
                return
            }
            guard let anchor = appDelegate.window else {
                completion(nil, CharmAuthError.other("No window to present sign-in from"))
                return
            }
            do {
                let user = try await session.signIn(anchor: anchor)
                setSignedInFlag(true)
                completion(user.sub, nil)
            } catch CharmAuthError.cancelled {
                completion(nil, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    static func enhanceScopes(completion: @escaping (String?, Error?) -> Void) {
        // The SDK requests the full configured scope list on every sign-in, so re-running
        // sign-in is how a missing scope gets (re-)granted.
        presentSignIn(completion: completion)
    }

    //MARK: - logout

    /// Revokes the sign-in at CHIS and deletes the tokens and key on this device.
    static func revokeAccessToken(completion: @escaping (Error?) -> Void) {
        signOut(completion: completion)
    }

    static func checkAndLogout(completion: @escaping (Error?) -> Void) {
        signOut(completion: completion)
    }

    private static func signOut(completion: @escaping (Error?) -> Void) {
        setSignedInFlag(false)
        Task { @MainActor in
            await Holder.session?.signOut()
            completion(nil)
        }
    }
}
