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
    
    init(size: CGSize, score: Int, highscore: Int) {
        super.init(size: size)
        
        let uglyFish = SKSpriteNode(imageNamed: "uglyFish")
        uglyFish.position = CGPoint(x: size.width / 2, y: size.height - 100)
        
        let messageLabel = SKLabelNode(text: "YOU DIED.")
        let scoreLabel = SKLabelNode(text: "Score: " + String(score))
        let highscoreLabel = SKLabelNode(text: "Highscore: " + String(highscore))
        messageLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 250)
        scoreLabel.position = CGPoint(x: size.width / 2, y: self.size.height - 300)
        highscoreLabel.position = CGPoint(x: size.width / 2, y: self.size.height - 350)
        
        addChild(uglyFish)
        addChild(messageLabel)
        addChild(scoreLabel)
        addChild(highscoreLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let skView = self.view as SKView!
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFit
        skView.presentScene(scene)
    }
}
