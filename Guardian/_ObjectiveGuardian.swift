// _ObjectiveGuardian.swift
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

@objc(GA0Guardian)
public class _ObjectiveGuardian: NSObject {

    let domain: String

    public init(domain: String) {
        self.domain = domain
    }

    public func enroll(usingUri uri: String, notificationToken: String, keyPair: RSAKeyPair, callback: @escaping (Enrollment?, NSError?) -> ()) {
        Guardian.enroll(forDomain: domain, usingUri: uri, notificationToken: notificationToken, keyPair: keyPair).start {
            switch $0 {
            case .success(let enrollment):
                callback(enrollment, nil)
            case .failure(let error):
                callback(nil, error as NSError)
            }
        }
    }

    public func allow(notification: Notification, enrollment: Enrollment, callback: @escaping (NSError?) -> ()) {
        Guardian.authentication(forDomain: domain, andEnrollment: enrollment).allow(notification: notification).start {
            switch $0 {
            case .success:
                callback(nil)
            case .failure(let error):
                callback(error as NSError)
            }
        }
    }

    public func reject(notification: Notification, andReason reason: String?, enrollment: Enrollment, callback: @escaping (NSError?) -> ()) {
        Guardian.authentication(forDomain: domain, andEnrollment: enrollment).reject(notification: notification, withReason: reason).start {
            switch $0 {
            case .success:
                callback(nil)
            case .failure(let error):
                callback(error as NSError)
            }
        }
    }

    public func notification(with userInfo: [AnyHashable: Any]) -> Notification? {
        return Guardian.notification(from: userInfo)
    }

    public func removeEnrollment(_ enrollment: Enrollment, callback: @escaping (NSError?) -> ()) {
        Guardian.api(forDomain: domain).device(forEnrollmentId: enrollment.id, token: enrollment.deviceToken).delete().start {
            switch $0 {
            case .success:
                callback(nil)
            case .failure(let error):
                callback(error as NSError)
            }
        }
    }
}
