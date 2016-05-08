//
//  EndScene.swift
//  Ugly Fish
//
//  Created by Martin  on 2016-05-07.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit

class EndScene: SKScene {
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(size: CGSize, score: Int) {
        super.init(size: size)
        
        let uglyFish = SKSpriteNode(imageNamed: "uglyFish")
        uglyFish.position = CGPoint(x: size.width / 2, y: size.height - 100)
        
        let foodLabel = SKLabelNode(text: "YOU DIED. \n Score: " + String(score))
        foodLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - uglyFish.size.height - 80)
        
        addChild(uglyFish)
        addChild(foodLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let skView = self.view as SKView!
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFit
        skView.presentScene(scene)
    }
}
