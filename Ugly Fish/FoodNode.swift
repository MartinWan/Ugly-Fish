//
//  FoodNode.swift
//  Ugly Fish
//
//  Created by Martin  on 2016-05-03.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit

enum FoodType:Int {
    case Normalfood = 0
    case specialfood = 1
}

class FoodNode: GenericNode {
    
    var foodType:FoodType!
    
    override func collisionWithPlayer(player: SKNode) {
        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 400)
        
        self.removeFromParent()
    }
}
