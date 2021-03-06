//
//  GameScene.swift
//  Ugly Fish
//
//  Created by Martin  on 2016-05-03.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit
import CoreMotion

struct CollisionBitMask {
    static let Player:UInt32 = 0x01
    static let Food:UInt32 = 0x02
    static let Rock:UInt32 = 0x03
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var background = SKNode()
    var foreground = SKNode()
    var hud = SKNode()
    
    var player = SKSpriteNode(imageNamed: "player")
    var uglyFish = SKSpriteNode(imageNamed: "uglyFish")
    
    var xAccelearation = CGFloat(0.0)
    let motionManager = CMMotionManager()
    
    let scoreLabel = SKLabelNode(fontNamed: "Helvetica")
    var score = 0
    let tapToStart = SKSpriteNode(imageNamed: "tapToStart")
    
    // for food, rock & background generation on levels
    // sprite nodes are generated between lastLevelStartingHeight and lastLevelStartinHeight + LEVEL_HEIGHT 
    var lastLevelStartingHeight = 0
    let LEVEL_HEIGHT = 10000
    var SPACING = 200
    // height between nodes on level
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // init background, foreground & hud
        initBackgroundAtHeight(0)
        addChild(background)
        addChild(foreground)
        addChild(hud)
        
        // init player
        player.position = CGPoint(x: self.size.width/2, y: 150)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody!.dynamic = false
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.restitution = 1
        player.physicsBody!.friction = 0
        player.physicsBody!.angularDamping = 0
        player.physicsBody!.linearDamping = 0
        player.physicsBody!.usesPreciseCollisionDetection = true
        player.physicsBody!.categoryBitMask = CollisionBitMask.Player
        player.physicsBody!.collisionBitMask = 0 // don't want player to ellastically (bounce) off other sprite nodes
        player.physicsBody!.contactTestBitMask = CollisionBitMask.Player | CollisionBitMask.Food | CollisionBitMask.Rock
        foreground.addChild(player)
        
        // init ugly fish behind player
        uglyFish.position = CGPoint(x: self.size.width / 2, y: -200)
        uglyFish.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: size.width, height: 10))
        uglyFish.physicsBody!.dynamic = false
        uglyFish.physicsBody!.allowsRotation = false
        uglyFish.physicsBody!.allowsRotation = false
        uglyFish.physicsBody!.restitution = 1
        uglyFish.physicsBody!.friction = 0
        uglyFish.physicsBody!.linearDamping = 0
        uglyFish.physicsBody!.usesPreciseCollisionDetection = true
        uglyFish.physicsBody!.categoryBitMask = CollisionBitMask.Player
        uglyFish.physicsBody!.collisionBitMask = 0
        uglyFish.physicsBody!.contactTestBitMask = CollisionBitMask.Player
        foreground.addChild(uglyFish)
        
        // init tap to start
        tapToStart.position = CGPoint(x: size.width/2, y: 300)
        tapToStart.size = CGSize(width: size.width * 0.7, height: size.height * 0.1)
        foreground.addChild(tapToStart)
        
        // init score label
        let scoreLabelImage = SKSpriteNode(imageNamed: "food")
        scoreLabelImage.position = CGPoint(x: 40, y: size.height - 50)
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: 80, y: size.height - 50)
        hud.addChild(scoreLabelImage)
        hud.addChild(scoreLabel)
        
        // create level's food and obstacles
        initRocksAtHeight(0)
        initFoodAtHeight(0)
        
        // init physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        // init accelerometer
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) { (data: CMAccelerometerData?, error:NSError?) -> Void in
            if let CMAccelerometerData = data {
                let acceleration = CMAccelerometerData.acceleration
                self.xAccelearation = CGFloat(acceleration.x) + self.xAccelearation * 0.25
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        // update ugly fish horizonatal position
        uglyFish.position.x = player.position.x
        
        // regenerate level if needed
        if player.position.y > CGFloat(lastLevelStartingHeight + LEVEL_HEIGHT) * 0.8 { // player has almost passed all generated objects on level
            
            SPACING = Int(Double(SPACING) * 0.8) // increase difficulty
            let levelEndY = lastLevelStartingHeight + LEVEL_HEIGHT
            lastLevelStartingHeight = Int(levelEndY)
            
            initBackgroundAtHeight(levelEndY)
            initRocksAtHeight(levelEndY)
            initFoodAtHeight(levelEndY)
        }
        
        // scroll background up if needed
        if player.position.y > 200 {
            background.position = CGPoint(x: 0, y: -(player.position.y - 200) / 10)
            foreground.position = CGPoint(x: 0, y: -(player.position.y - 200))
        }
        
        // remove rock nodes off screen
        foreground.enumerateChildNodesWithName("rock") { (node, stop) -> Void in
            if node.position.y < self.player.position.y - 300 {
                self.removeFromParent()
            }
        }
            
        // remove food nodes off screen
        foreground.enumerateChildNodesWithName("food") { (node, stop) -> Void in
            if node.position.y < self.player.position.y - 300 {
                self.removeFromParent()
            }
        }
    }
    
    override func didSimulatePhysics() {
        
        // adjust x-acceleration due to accelerometer
        player.physicsBody?.velocity = CGVector(dx: xAccelearation * 600, dy: player.physicsBody!.velocity.dy)
        
        // if player too far left of screen, appear on right side and vice versa
        if player.position.x < -10 {
            player.position = CGPoint(x: self.size.width + 10, y: player.position.y)
        } else if (player.position.x > self.size.width + 10) {
            player.position = CGPoint(x: -10, y: player.position.y)
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if player.physicsBody!.dynamic {
            return
        }
        
        
        tapToStart.removeFromParent()
        
        player.physicsBody!.dynamic = true
        player.physicsBody!.velocity = CGVector(dx: 0, dy: 250)
        
        uglyFish.physicsBody!.dynamic = true
        uglyFish.physicsBody!.velocity = player.physicsBody!.velocity
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var otherNode:SKNode!
        
        if contact.bodyA.node == player && contact.bodyB.node == uglyFish {
            endGame()
        }
        
        if contact.bodyB.node == player && contact.bodyA.node == uglyFish {
            endGame()
        }
        
        // set otherNode to non-player or non-ugly-fish node
        if contact.bodyA.node != player {
            otherNode = contact.bodyA.node
        } else {
            otherNode = contact.bodyB.node
        }
 
        if otherNode is FoodNode {
            player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 250)
            otherNode.removeFromParent()
            score += 1
            scoreLabel.text = String(score)
        }
        
        if otherNode is RockNode {
            if (otherNode as! RockNode).rockType == RockType.breakableRock {
                // slow down player upwards velocity
                player.physicsBody?.velocity.dy *= 0.8
                otherNode.removeFromParent()
                
            } else { // rockType is unbreakable
                player.physicsBody?.velocity.dy *= 0.3
                otherNode.removeFromParent()
            }
        }
    }
    
    func initBackgroundAtHeight(height: Int) -> Void {
        var y = height
        
        while y < height + LEVEL_HEIGHT {
            
            let backgroundImage = SKSpriteNode(imageNamed: "ocean")
            backgroundImage.position = CGPoint(x: Int(size.width / 2), y: y)
            background.addChild(backgroundImage)
           
            y += SPACING
        }
    }
    
    func initRocksAtHeight(height: Int) -> Void {
        var y = height

        while y < height + LEVEL_HEIGHT {
            
            let x = random() % Int(size.width)
            
            var type:RockType
            if random() % 2 == 0 {
                type = RockType.breakableRock
            } else {
                type = RockType.normalRock
            }
            
            let rock = createRockAtPosition(CGPoint(x: x, y: y), ofType: type)
            foreground.addChild(rock)
            
            y += SPACING
        }
    }
    
    func initFoodAtHeight(height: Int) -> Void {
        var y = height

        while y < height + LEVEL_HEIGHT {
            
            let x = random() % Int(size.width)
            
            var type:FoodType
            if random() % 2 == 0 {
                type = FoodType.Normalfood
            } else {
                type = FoodType.specialfood
            }

            let food = createFoodAtPosition(CGPoint(x: x, y: y), ofType: type)
            foreground.addChild(food)
            
            y += SPACING
        }
    }
    
    func createRockAtPosition(position: CGPoint, ofType type:RockType) -> RockNode {
        let node = RockNode()
        node.position = position
        node.name = "rock"
        node.rockType = type
        
        var sprite:SKSpriteNode
        
        if type == RockType.normalRock {
            sprite = SKSpriteNode(imageNamed: "bait")
        } else {
            sprite = SKSpriteNode(imageNamed: "rockBreak")
        }
        node.addChild(sprite)
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.height/2)
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = CollisionBitMask.Rock
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
    
    func createFoodAtPosition(position: CGPoint, ofType type:FoodType) -> FoodNode {
        let node = FoodNode()
        node.position = position
        node.name = "food"
        node.foodType = type
        
        var sprite:SKSpriteNode
        
        if type == FoodType.Normalfood {
            sprite = SKSpriteNode(imageNamed: "food")
        } else {
            sprite = SKSpriteNode(imageNamed: "food") // need special food image and use for special food
        }
        node.addChild(sprite)
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = CollisionBitMask.Food
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }

    func endGame() {
        // save high score
        let userData = NSUserDefaults.standardUserDefaults()
        let highscore = userData.integerForKey("highscore")
        userData.setInteger(max(score, highscore), forKey: "highscore")
        userData.synchronize()
        
        // transition to EndScene
        let transition = SKTransition.doorsCloseHorizontalWithDuration(1)
        let endScene = EndScene(size: self.size, score: score, highscore: userData.integerForKey("highscore"))
        self.view?.presentScene(endScene, transition: transition)
    }
    
}



