//
//  ShareSection.swift
//  PHR
//
//  Created by Prathiba M on 21/08/25.
//  Copyright © 2025 Dhanuprasanya P. All rights reserved.
//

struct ShareSection: Identifiable {
    var id = UUID()
    var isActive: Bool = false
    var practiceId: String? = nil
    var practiceName: String? = nil
    var sectionsList: [String] = []
    var facilitiesName: String? = nil
}
