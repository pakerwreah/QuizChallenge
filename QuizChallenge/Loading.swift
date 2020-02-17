//
//  Loading.swift
//  QuizChallenge
//
//  Created by Carlos on 11/02/20.
//  Copyright © 2020 ArcTouch. All rights reserved.
//

import UIKit

class Loading: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
