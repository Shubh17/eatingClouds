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
    
    var inGame = false
    var score = 0
    let highScoreKey = "com.clouds.highscore"
    
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var playAgainLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        //physics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0.0)
        self.physicsWorld.contactDelegate = self
        
        //setting background color
//        let backgroundColor = SKColor(red: 42.0/255.0, green: 115.0/255.0, blue: 234.0/255.0, alpha: 1.0)
//        self.backgroundColor = backgroundColor
        
        // city image backgound
        // needs to fit better
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
            self.addChild(backgroundNode)
        }
        
        //spiderman
        //let and var
        let textureOne = SKTexture(imageNamed: "./pics/standing.png")//1 param
        let textureTwo = SKTexture(imageNamed: "./pics/sideshot.png")
        textureOne.filteringMode = .nearest
        textureTwo.filteringMode = .nearest
        
        let animation = SKAction.animate(with: [textureOne, textureTwo], timePerFrame:0.2)
        let walking = SKAction.repeatForever(animation)
        spiderman = SKSpriteNode(texture: textureOne)
        spiderman.setScale(0.8)
        spiderman.position = CGPoint(x: self.frame.width * 0.2, y: self.frame.height * 0.4)
        
        spiderman.run(walking)
        
        spiderman.physicsBody = SKPhysicsBody(rectangleOf: spiderman.size)
        spiderman.physicsBody?.isDynamic = true
        spiderman.physicsBody?.allowsRotation = false
        spiderman.physicsBody?.density = CGFloat(5)
        
        spiderman.physicsBody?.categoryBitMask = personCategory
        spiderman.physicsBody?.collisionBitMask = cloudCategory | groundCategory
        spiderman.physicsBody?.contactTestBitMask = cloudCategory | groundCategory
        
        self.addChild(spiderman)
        
        //cloud textures
        clouds = SKNode()
        self.addChild(clouds)
        
        cloudTexture1 = SKTexture(imageNamed: "./clouds/cloud1.png")
        cloudTexture1.filteringMode = .nearest
        cloudTexture2 = SKTexture(imageNamed: "./clouds/cloud2.png")
        cloudTexture2.filteringMode = .nearest
        cloudTexture3 = SKTexture(imageNamed: "./clouds/cloud3.png")
        cloudTexture3.filteringMode = .nearest
        
        //cloud movement
        let distanceToMove = CGFloat(self.frame.width * cloudTexture1.size().width)
        let cloudMoves = SKAction.moveBy(x: -distanceToMove * 0.5, y: 0.0, duration: TimeInterval(0.01 * distanceToMove))
        let removeCloud = SKAction.removeFromParent()
        moveCloudAndRemove = SKAction.sequence([cloudMoves, removeCloud])
        
        //spawn clouds
        let spawn = SKAction.run(makeCloudsAndRemove)
        let randomTime = Double(arc4random_uniform(30))/10.0 + 1.0
        let delay = SKAction.wait(forDuration: TimeInterval(randomTime))
        let spawnAndRemoveForever = SKAction.repeatForever(SKAction.sequence([spawn, delay]))
        //self.run(spawnAndRemoveForever)
        
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
        let cloudNode = SKNode()
        
        let cloud = SKSpriteNode(texture: cloudTexture1)
        cloud.setScale(2.5)
        
        cloudNode.position = CGPoint(x: self.frame.width + (cloud.size.width * 0.3),
                                    y: self.frame.height * CGFloat(arc4random_uniform(5))/10 + cloud.size.height)
        
        cloudNode.addChild(cloud)
        
        cloudNode.physicsBody = SKPhysicsBody(rectangleOf: cloud.size)
        cloudNode.physicsBody?.isDynamic = false
        cloudNode.physicsBody?.categoryBitMask = cloudCategory
        cloudNode.physicsBody?.contactTestBitMask = personCategory
        
        cloudNode.run(moveCloudAndRemove)
        clouds.addChild(cloudNode)
    }
    
    func resetScene(){
        score = 0
        inGame = true
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
        for _ in touches {
            spiderman.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            spiderman.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: self.frame.height * 0.75))
            score += 1
            scoreLabel?.text = String(score)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func isInContactWith(_ contact: SKPhysicsContact, bitmask: UInt32) -> Bool {
        return contact.bodyA.categoryBitMask & bitmask == bitmask ||
            contact.bodyB.categoryBitMask & bitmask == bitmask
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if inGame && isInContactWith(contact, bitmask: groundCategory) { // if we hit the ground
            inGame = false
            spiderman.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            checkScoreAndStore()
            self.addChild(playAgainLabel)
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
