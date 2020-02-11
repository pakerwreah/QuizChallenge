//
//  Utils.swift
//  QuizChallenge
//
//  Created by Carlos on 11/02/20.
//  Copyright © 2020 ArcTouch. All rights reserved.
//

import Foundation

func thread(_ run: @escaping () -> Void) {
    DispatchQueue.global().async {
        run()
    }
}

func main(_ run: @escaping () -> Void) {
    DispatchQueue.main.async {
        run()
    }
}
