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
    private static let legacyPasswordKey = "password"

    static var userName: String {
        get {
            return userDefaults.string(forKey: "userName") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "userName")
        }
    }

    static var password: String {
        get {
            if let storedPassword = KeychainPassword.read() {
                deleteLegacyPassword()
                return storedPassword
            }

            let legacyPassword = userDefaults.string(forKey: legacyPasswordKey) ?? ""
            if legacyPassword.isEmpty {
                return ""
            }

            if KeychainPassword.save(legacyPassword) {
                deleteLegacyPassword()
            }
            return legacyPassword
        }
        set {
            deleteLegacyPassword()
            if newValue.isEmpty {
                KeychainPassword.delete()
            } else {
                KeychainPassword.save(newValue)
            }
        }
    }

    /// Removes a password written by older builds. UserDefaults stores this value in plaintext.
    private static func deleteLegacyPassword() {
        guard userDefaults.object(forKey: legacyPasswordKey) != nil else {
            return
        }
        userDefaults.removeObject(forKey: legacyPasswordKey)
    }

}

private enum KeychainPassword {
    private static let service = "com.Taly.sdkTest"
    private static let account = "merchantPassword"

    private static var query: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    static func read() -> String? {
        var readQuery = query
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
    static func save(_ password: String) -> Bool {
        let data = Data(password.utf8)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return true
        }
        guard updateStatus == errSecItemNotFound else {
            return false
        }

        var addQuery = query
        for (key, value) in attributes {
            addQuery[key] = value
        }
        return SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess
    }

    static func delete() {
        SecItemDelete(query as CFDictionary)
    }
}
