//
//  Exponea.swift
//  ExponeaSDKShared
//
//  Created by Panaxeo on 05/03/2020.
//  Copyright © 2020 Exponea. All rights reserved.
//

import Foundation

public class Exponea {
    public static let version = "3.0.1"
    /// A logger used to log all messages from the SDK.
    public static var logger: Logger = Logger()

    public static func convertFcmPayloadToExponeaPayload(fcmPayload: [AnyHashable : Any]) -> [AnyHashable : Any] {
        guard let message = fcmPayload["message"] as? [String: Any],
            let notification = message["notification"] as? [String: Any],
            let data = message["data"] as? [String: Any] else {
            return [:]
        }

        var exponeaPayload: [String: Any] = [:]

        // Map common fields
        exponeaPayload["notification_id"] = data["notification_id"]
        exponeaPayload["title"] = notification["title"]
        exponeaPayload["message"] = notification["body"]
        if let image = data["image"] { exponeaPayload["image"] = image }
        if let sound = data["sound"] { exponeaPayload["sound"] = sound }
        exponeaPayload["source"] = data["source"]
        exponeaPayload["silent"] = data["silent"] as? Bool ?? false
        exponeaPayload["has_tracking_consent"] = data["has_tracking_consent"] as? Bool ?? true
        exponeaPayload["consent_category_tracking"] = data["consent_category_tracking"]

        // Map URL and actions
        if let url = data["url"] { exponeaPayload["url"] = url }
        if let actions = data["actions"] as? [[String: Any]] {
            exponeaPayload["actions"] = actions.map { action in
                return [
                    "title": action["title"] ?? "",
                    "action": action["action"] ?? "",
                    "url": action["url"] ?? ""
                ]
            }
        }

        // Map APS
        exponeaPayload["aps"] = [
            "alert": [
                "title": notification["title"] ?? "",
                "body": notification["body"] ?? ""
            ],
            "mutable-content": 1
        ]

        // Map attributes
        exponeaPayload["attributes"] = data

        // Map URL params
        if let url_params = data["url_params"] { exponeaPayload["url_params"] = url_params }

        return exponeaPayload
    }
    
    public static func isExponeaNotification(userInfo: [AnyHashable: Any]) -> Bool {
        return userInfo["source"] as? String == "xnpe_platform"
    }
}
