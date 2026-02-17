import Foundation
import WebKit

final class ProfileLogoutService {

    static let shared = ProfileLogoutService()
    private init() {}

    func logout() {
        OAuth2TokenStorage.shared.token = nil
        cleanCookies()
        cleanServices()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
        }
    }

    private func cleanServices() {
        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()
    }
}
