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

class RockNode: GenericNode {
    
    var rockType:RockType!
    
    override func collisionWithPlayer(player: SKNode) {
        
        if rockType == RockType.breakableRock {
            
            // slow down player upwards velocity
            player.physicsBody?.velocity.dy *= 0.8
            self.removeFromParent()
            
        } else { // rockType is unbreakable
            player.physicsBody?.velocity.dy = -0.8
        }
        
    }
}
