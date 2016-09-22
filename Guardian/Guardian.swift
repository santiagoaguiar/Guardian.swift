// Guardian.swift
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

public struct Guardian {

    let api: API
    let codeGenerator: CodeGenerator
    
    init(apiClient: API, codeGenerator: CodeGenerator) {
        self.api = apiClient
        self.codeGenerator = codeGenerator
    }
    
    public init(baseUrl: NSURL, session: NSURLSession = NSURLSession.sharedSession()) {
        self.init(apiClient: APIClient(baseUrl: baseUrl, session: session), codeGenerator: TOTPCodeGenerator())
    }

    public func enroll(withURI enrollmentUri: String, notificationToken: String) -> EnrollRequest {
        return EnrollRequest(api: api, enrollmentUri: enrollmentUri, notificationToken: notificationToken)
    }

    public func delete(enrollment enrollment: Enrollment) -> Request<Void> {
        return api
            .device(forEnrollmentId: enrollment.id, token: enrollment.deviceToken)
            .delete()
    }

    public func allow(notification notification: AuthenticationNotification, enrollment: Enrollment) throws -> Request<Void> {
        return api
            .allow(transaction: notification.transactionToken, withCode: try codeGenerator.code(forEnrollment: enrollment))
    }

    public func reject(notification notification: AuthenticationNotification, enrollment: Enrollment, reason: String? = nil) throws -> Request<Void> {
        return api
            .reject(transaction: notification.transactionToken, withCode: try codeGenerator.code(forEnrollment: enrollment), reason: reason)
    }
}

protocol CodeGenerator {
    func code(forEnrollment enrollment: Enrollment) throws -> String
}

struct TOTPCodeGenerator : CodeGenerator {
    func code(forEnrollment enrollment: Enrollment) throws -> String {
        let generator = try TOTP(withBase32Secret: enrollment.base32Secret, period: enrollment.period, algorithm: enrollment.algorithm)
        return generator.generate(digits: enrollment.digits, counter: Int(NSDate().timeIntervalSince1970))
    }
}
