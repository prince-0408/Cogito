import SwiftUI

// TabBarItem.swift
struct TabBarItem: Hashable {
    let iconName: String
    let title: String
    let tab: Tab
    
    // Custom hash implementation for Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}