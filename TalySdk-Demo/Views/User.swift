//
//  User.swift
//  TalySdk-Demo
//
//  Created by Mehul Goswami on 06/09/23.
//

import Foundation
import Security

class User {
    private static let userDefaults = UserDefaults.standard

    static var merchantKey: String {
        get { secret(account: "merchantKey") }
        set { setSecret(newValue, account: "merchantKey") }
    }

    static var merchantSecret: String {
        get { secret(account: "merchantSecret") }
        set { setSecret(newValue, account: "merchantSecret") }
    }

    static var clientId: String {
        get { secret(account: "clientId") }
        set { setSecret(newValue, account: "clientId") }
    }

    static var clientSecret: String {
        get { secret(account: "clientSecret") }
        set { setSecret(newValue, account: "clientSecret") }
    }

    /// Drops credentials saved in UserDefaults by older demo builds.
    static func deleteLegacyUserDefaultsSecrets() {
        userDefaults.removeObject(forKey: "password")
        userDefaults.removeObject(forKey: "userName")
        userDefaults.removeObject(forKey: "clientId")
        userDefaults.removeObject(forKey: "clientSecret")
        KeychainSecret.delete(account: "checkoutAccessToken")
        KeychainSecret.delete(account: "merchantPassword")
        KeychainSecret.delete(account: "password")
    }

    private static func secret(account: String) -> String {
        KeychainSecret.read(account: account) ?? ""
    }

    private static func setSecret(_ value: String, account: String) {
        if value.isEmpty {
            KeychainSecret.delete(account: account)
        } else {
            KeychainSecret.save(value, account: account)
        }
    }
}

private enum KeychainSecret {
    private static let service = "com.Taly.sdkTest"

    private static func query(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    static func read(account: String) -> String? {
        var readQuery = query(account: account)
        readQuery[kSecReturnData as String] = true
        readQuery[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(readQuery as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    static func save(_ secret: String, account: String) -> Bool {
        let data = Data(secret.utf8)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let baseQuery = query(account: account)
        let updateStatus = SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return true
        }
        guard updateStatus == errSecItemNotFound else {
            return false
        }

        var addQuery = baseQuery
        for (key, value) in attributes {
            addQuery[key] = value
        }
        return SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess
    }

    static func delete(account: String) {
        SecItemDelete(query(account: account) as CFDictionary)
    }
}
