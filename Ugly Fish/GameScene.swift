//
//  GameScene.swift
//  Ugly Fish
//
//  Created by Martin  on 2016-05-03.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var background = SKNode()
    var foreground = SKNode()
    var hud = SKNode()
    
    var player = SKSpriteNode(color: UIColor.brownColor(), size: CGSize.init(width: 0, height: 0))
    var xAccelearation = CGFloat(0.0)
    let motionManager = CMMotionManager()
    
    let scoreLabel = SKLabelNode(fontNamed: "Helvetica")
    var score = 0
    let tapToStart = SKSpriteNode(imageNamed: "tapToStart")
    
    /* for food, rock generation on levels */
    var lastLevelStartingHeight = 0
    let LEVEL_HEIGHT = 10000
    let SPACING = 200 // height between nodes on level
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // init background & foreground
        backgroundColor = SKColor.blueColor()  // TODO: CREATE & LOAD OCEAN GRAPHIC
        addChild(background)
        addChild(foreground)
        addChild(hud)
        
        // init player
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: self.size.width/2, y: 80)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody!.dynamic = false
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.restitution = 1
        player.physicsBody!.friction = 0
        player.physicsBody!.angularDamping = 0
        player.physicsBody!.linearDamping = 0
        player.physicsBody!.usesPreciseCollisionDetection = true
        player.physicsBody!.categoryBitMask = CollisionBitMask.Player
        player.physicsBody!.collisionBitMask = 0
        player.physicsBody!.contactTestBitMask = CollisionBitMask.Food | CollisionBitMask.Rock
        foreground.addChild(player)

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
        
        // regenerate level if needed
        if player.position.y > CGFloat(lastLevelStartingHeight + LEVEL_HEIGHT) { // player has passed all generated objects on level
            lastLevelStartingHeight = Int(player.position.y)
            initRocksAtHeight(Int(player.position.y))
            initFoodAtHeight(Int(player.position.y))
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
        player.physicsBody!.velocity = CGVector(dx: 0, dy: 300)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var otherNode:SKNode!
        
        // set otherNode to non-player node
        if contact.bodyA.node != player {
            otherNode = contact.bodyA.node
        } else {
            otherNode = contact.bodyB.node
        }
        
        (otherNode as! GenericNode).collisionWithPlayer(player) //colisionWithPlayer is implemented by subclasses of GenericNode
        
        if otherNode is FoodNode {
            score += 1
            scoreLabel.text = String(score)
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
            sprite = SKSpriteNode(imageNamed: "rock")
        } else {
            sprite = SKSpriteNode(imageNamed: "rockBreak")
        }
        node.addChild(sprite)
        node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
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
            sprite = SKSpriteNode(imageNamed: "bait")
        }
        node.addChild(sprite)
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = CollisionBitMask.Food
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
}
