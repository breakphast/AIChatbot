//
//  ABTestService.swift
//  AIChatbot
//
//  Created by Desmond Fitch on 3/18/25.
//


import SwiftUI

@MainActor
protocol ABTestService: Sendable {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
    func fetchUpdatedConfig() async throws -> ActiveABTests
}