//
//  RockNode.swift
//  Ugly Fish
//
//  Created by Martin  on 2016-05-03.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit

enum RockType:Int {
    case normalRock = 0
    case breakableRock = 1
}

class RockNode: SKNode {
    
    var rockType:RockType!

}
 
