//
//  TabBarItem.swift
//  Cogito
//
//  Created by Prince Yadav on 25/11/24.
//


import SwiftUI

struct TabBarItem: Hashable {
    let iconName: String
    let title: String
    let tab: Tab
    
    // Custom hash implementation for Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
