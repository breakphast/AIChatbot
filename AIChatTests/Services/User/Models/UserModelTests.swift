//
//  UserModelTests.swift
//  AIChatTests
//
//  Created by Desmond Fitch on 3/21/25.
//

import SwiftUI
import Testing
@testable import AIChatbot

struct UserModelTests {
    
    @Test("UserModel initializes correctly with all properties")
    func testFullInit() throws {
        let model = UserModel(
            userID: .random,    
            email: .email,
            isAnonymous: .random,
            creationDate: .random,
            creationVersion: .random,
            lastSignInDate: .random,
            didCompleteOnboarding: .random,
            profileColorHex: .hexColor
        )

        #expect(!model.userID.isEmpty)
        #expect(model.email?.contains("@") == true)
        #expect(model.creationDate != nil)
        #expect(model.creationVersion?.isEmpty == false)
        #expect(model.lastSignInDate != nil)
        #expect(model.didCompleteOnboarding != nil)
        #expect(model.profileColorHex?.hasPrefix("#") == true)
    }

    @Test("UserModel profileColorConverted defaults to .accent")
    func testDefaultProfileColor() throws {
        let model = UserModel(userID: .random)
        #expect(model.profileColorConverted == .accent)
    }

    @Test("UserModel creates from UserAuthInfo")
    func testAuthInit() throws {
        let auth = UserAuthInfo(
            uid: .random,
            email: .email,
            isAnonymous: .random,
            creationDate: .random,
            lastSignInDate: .random
        )

        let model = UserModel(auth: auth, creationVersion: .random)

        #expect(model.userID == auth.uid)
        #expect(model.email == auth.email)
        #expect(model.isAnonymous == auth.isAnonymous)
        #expect(model.creationDate == auth.creationDate)
        #expect(model.lastSignInDate == auth.lastSignInDate)
        #expect(model.creationVersion == nil) // not passed through this init
    }

    @Test("UserModel eventParameters omits nil values")
    func testEventParameters() throws {
        let model = UserModel(
            userID: .random,
            email: .email,
            isAnonymous: .random
        )

        let params = model.eventParameters

        #expect(params["user_user_id"] != nil)
        #expect(params["user_email"] != nil)
        #expect(params["user_is_anonymous"] != nil)
        #expect(params["user_creation_date"] == nil)
    }

    @Test("UserModel mock returns expected structure")
    func testMockData() throws {
        let mock = UserModel.mock
        #expect(!mock.userID.isEmpty)
        #expect(mock.didCompleteOnboarding != nil)
        #expect(mock.profileColorHex?.hasPrefix("#") == true)
    }

    @Test("UserModel encodes and decodes properly with Codable using truncatedToSeconds")
    func testCodableRoundTrip() throws {
        let original = UserModel(
            userID: .random,
            email: .email,
            isAnonymous: .random,
            creationDate: .random,
            creationVersion: .random,
            lastSignInDate: .random,
            didCompleteOnboarding: .random,
            profileColorHex: .hexColor
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let decoded = try decoder.decode(UserModel.self, from: data)

        #expect(decoded.userID == original.userID)
        #expect(decoded.email == original.email)
        #expect(decoded.isAnonymous == original.isAnonymous)
        #expect(decoded.creationVersion == original.creationVersion)
        #expect(decoded.didCompleteOnboarding == original.didCompleteOnboarding)
        #expect(decoded.profileColorHex == original.profileColorHex)

        #expect(decoded.creationDate?.truncatedToSeconds == original.creationDate?.truncatedToSeconds)
        #expect(decoded.lastSignInDate?.truncatedToSeconds == original.lastSignInDate?.truncatedToSeconds)
    }
}
