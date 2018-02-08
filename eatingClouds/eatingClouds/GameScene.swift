//
//  GameScene.swift
//  eatingClouds
//
//  Created by John Kuhn on 1/19/18.
//  Copyright © 2018 John Kuhn. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let personCategory: UInt32 = 1 << 0
    let cloudCategory: UInt32 = 1 << 1
    let groundCategory: UInt32 = 1 << 2
    
    var clouds: SKNode!
    
    var cloudTexture1: SKTexture!
    var cloudTexture2: SKTexture!
    var cloudTexture3: SKTexture!
    
    var moveCloudAndRemove: SKAction!
    
    var spiderman: SKSpriteNode!
    var touchLength = 0.0
    
    var inGame = false
    var score = 0
    let highScoreKey = "com.clouds.highscore"
    var hitFirstCloud = false
    
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var playAgainLabel: SKLabelNode!
    
    var moving: SKNode!
    
    override func didMove(to view: SKView) {
        //physics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0.0)
        self.physicsWorld.contactDelegate = self
        
        moving = SKNode()
        moving.speed = 0.0 // all the children will also follow this speed
        self.addChild(moving)
        
        // city image backgound
        let cityTexture = SKTexture(imageNamed: "./pics/fullsize.png")
        cityTexture.filteringMode = .nearest
        let scale = (self.frame.size.height + 10) / cityTexture.size().height
        
        let cityMovement = SKAction.moveBy(x: -cityTexture.size().width * scale, y: 0.0,
                                           duration: TimeInterval(cityTexture.size().width * 0.05))
        let resetCity = SKAction.moveBy(x: cityTexture.size().width * scale, y: 0.0, duration: TimeInterval(0.0))
        let moveBackground = SKAction.sequence([cityMovement, resetCity])
        
        for x in 0..<2 {
            let backgroundNode = SKSpriteNode(texture: cityTexture)
            backgroundNode.setScale(scale)
            let offset = CGFloat(x) * cityTexture.size().width * scale // the first one will be 0
            backgroundNode.position = CGPoint(x: (cityTexture.size().width * 0.5 * scale) + offset,
                                              y: cityTexture.size().height * 0.5 * scale)
            backgroundNode.zPosition = -1
            backgroundNode.run(SKAction.repeatForever(moveBackground))
            moving.addChild(backgroundNode)
        }
        
        //spiderman
        let textureOne = SKTexture(imageNamed: "./pics/standing.png")//1 param
        let textureTwo = SKTexture(imageNamed: "./pics/sideshot.png")
        textureOne.filteringMode = .nearest
        textureTwo.filteringMode = .nearest
        
        //walking animation
        let animation = SKAction.animate(with: [textureOne, textureTwo], timePerFrame:0.2)
        let walking = SKAction.repeatForever(animation)
        spiderman = SKSpriteNode(texture: textureOne)
        spiderman.setScale(0.8)
        spiderman.position = CGPoint(x: self.frame.width * 0.2, y: self.frame.height * 0.4)
        
        spiderman.physicsBody = SKPhysicsBody(rectangleOf: spiderman.size) // needs converted to texture size
        spiderman.physicsBody?.isDynamic = true
        spiderman.physicsBody?.allowsRotation = false
        spiderman.physicsBody?.density = CGFloat(5)
        spiderman.physicsBody?.restitution = 0.0
        
        spiderman.physicsBody?.categoryBitMask = personCategory
        spiderman.physicsBody?.collisionBitMask = cloudCategory | groundCategory
        spiderman.physicsBody?.contactTestBitMask = cloudCategory | groundCategory
        
        spiderman.run(walking)
        self.addChild(spiderman)
        
        //cloud textures
        clouds = SKNode()
        moving.addChild(clouds)
        
        cloudTexture1 = SKTexture(imageNamed: "./clouds/cloud1.png")
        cloudTexture1.filteringMode = .nearest
        cloudTexture2 = SKTexture(imageNamed: "./clouds/cloud2.png")
        cloudTexture2.filteringMode = .nearest
        cloudTexture3 = SKTexture(imageNamed: "./clouds/cloud3.png")
        cloudTexture3.filteringMode = .nearest
        
        //cloud movement
        let distanceToMove = CGFloat(self.frame.size.width + cloudTexture1.size().width)
        let cloudMoves = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.005 * distanceToMove))
        let removeCloud = SKAction.removeFromParent()
        moveCloudAndRemove = SKAction.sequence([cloudMoves, removeCloud])
        
        //spawn clouds
        let spawn = SKAction.run(makeCloudsAndRemove)
        let randomTime = Double(arc4random_uniform(40))/10.0 + 1.0 //make this random every time
        let delay = SKAction.wait(forDuration: TimeInterval(randomTime))
        let spawnAndRemoveForever = SKAction.repeatForever(SKAction.sequence([spawn, delay]))
        self.run(spawnAndRemoveForever)
        
        //ground
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: -1)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        self.addChild(ground)
        
        //score
        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.position = CGPoint(x: self.frame.size.width - 50, y: self.frame.size.height - 80)
        scoreLabel.fontSize = 70
        self.addChild(scoreLabel)
        
        //play again
        playAgainLabel = SKLabelNode(fontNamed: "Arial")
        playAgainLabel.fontSize = 70
        playAgainLabel.numberOfLines = 2
        playAgainLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 350)
        playAgainLabel.text = "Tap to Play Again"
    }
    
    func makeCloudsAndRemove(){
        if !inGame { // don't spawn clouds till game starts
            return
        }
        let cloud = SKSpriteNode(texture: cloudTexture1)
        cloud.setScale(2.5)
        
        cloud.position = CGPoint(x: self.frame.width + (cloud.size.width * 0.3),
                                 y: self.frame.height * CGFloat(arc4random_uniform(5))/10 + cloud.size.height)
        
        cloud.physicsBody = SKPhysicsBody(texture: cloudTexture1, size: CGSize(width: cloud.size.width, height: cloud.size.height))
        cloud.physicsBody?.isDynamic = false
        cloud.physicsBody?.categoryBitMask = cloudCategory
        cloud.physicsBody?.restitution = 0.0
        
        cloud.run(moveCloudAndRemove)
        clouds.addChild(cloud)
    }
    
    func resetScene(){
        score = 0
        inGame = true
        moving.speed = 1.0
        hitFirstCloud = false
        spiderman.position = CGPoint(x: self.frame.width * 0.2, y: self.frame.height * 0.4)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        highScoreLabel?.removeFromParent()
        playAgainLabel?.removeFromParent()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !inGame {
            resetScene()
            return
        }
        if moving.speed == 0.0 {
            touchLength = event!.timestamp
            return
        }
        if hitFirstCloud {
            return
        }
        for _ in touches {
            spiderman.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            spiderman.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: self.frame.height * 0.75))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if moving.speed == 0.0 && touchLength > 0 {
            moving.speed = 1.0
            touchLength = event!.timestamp - touchLength
            
            //apply a jump based on length of press
            spiderman.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: self.frame.height * 1.5 * CGFloat(touchLength)))
            
            touchLength = 0.0
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        scoreLabel?.text = "\(score)"
        if spiderman.position.x <= 0 {
            inGame = false
            moving.speed = 0.0
            clouds.removeAllChildren()
            spiderman.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            checkScoreAndStore()
            self.addChild(playAgainLabel)
        }
    }
    
    func isInContactWith(_ contact: SKPhysicsContact, bitmask: UInt32) -> Bool {
        return contact.bodyA.categoryBitMask & bitmask == bitmask ||
            contact.bodyB.categoryBitMask & bitmask == bitmask
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if !inGame {
            return
        }
        if isInContactWith(contact, bitmask: groundCategory) { // if we hit the ground
            inGame = false
            moving.speed = 0.0
            clouds.removeAllChildren()
            spiderman.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            checkScoreAndStore()
            self.addChild(playAgainLabel)
        } else if isInContactWith(contact, bitmask: cloudCategory) { //if we hit a cloud
            score += 1
            moving.speed = 0.0
            hitFirstCloud = true
            //this is where now want to charge a jump
        }
    }
    
    fileprivate func checkScoreAndStore() {
        let highScore = UserDefaults.standard.integer(forKey: highScoreKey)
        if score > Int(highScore) {
            //highscore
            highScoreLabel = SKLabelNode(fontNamed: "Arial")
            highScoreLabel.fontSize = 100
            highScoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 250)
            highScoreLabel.text = "HIGH SCORE"
            self.addChild(highScoreLabel)
            
            UserDefaults.standard.set(score, forKey: highScoreKey)
            UserDefaults.standard.synchronize()
        }
    }
    
}
