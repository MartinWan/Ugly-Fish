//
//  GenericNode.swift
//  Ugly Fish
//
//  Created by Martin  on 2016-05-03.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit

struct CollisionBitMask {
    static let Player:UInt32 = 0x00
    static let Food:UInt32 = 0x01
    static let Rock:UInt32 = 0x02
}


class GenericNode: SKNode {
    
    func collisionWithPlayer(player: SKNode) {
        // intentionally empty
    }
    
    func shouldRemoveNode(playerY: CGFloat) {
        if playerY > self.position.y + 300 {
            self.removeFromParent()
        }
    }
}
