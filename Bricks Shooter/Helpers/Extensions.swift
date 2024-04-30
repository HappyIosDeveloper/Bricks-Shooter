//
//  Extensions.swift
//  Bricks Shooter
//
//  Created by Ahmadreza on 4/30/24.
//  Copyright © 2024 Ahmadreza. All rights reserved.
//

import SpriteKit

func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
    let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    return (rand) * (to - from) + from
}

extension Bool {
    
    func randomWith(weight: Int)-> Bool {
        let numbers = Array(0...100)
        return numbers.randomElement()! < weight
    }
}

var hasNotch: Bool {
    if #available(iOS 11.0, tvOS 11.0, *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
    return false
}

extension Int {
    
    func toBrickNumber()-> String {
        if Array(0...10).contains(self) {
            return "brick1"
        } else if Array(11...20).contains(self) {
            return "brick2"
        } else if Array(21...30).contains(self) {
            return "brick3"
        } else if Array(31...40).contains(self) {
            return "brick4"
        } else if Array(41...50).contains(self) {
            return "brick5"
        } else if Array(51...60).contains(self) {
            return "brick6"
        } else {
            return "brick7"
        }
    }
}
