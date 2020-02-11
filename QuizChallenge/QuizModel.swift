//
//  QuizModel.swift
//  QuizChallenge
//
//  Created by Carlos on 11/02/20.
//  Copyright © 2020 ArcTouch. All rights reserved.
//

import Foundation

struct QuizModel: Codable {
    var question: String
    var answer: [String]
}
