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
    
    var clouds: SKNode!
    
    var cloudTexture1: SKTexture!
    var cloudTexture2: SKTexture!
    var cloudTexture3: SKTexture!
    
    var moveCloudAndRemove: SKAction!
    
    var spiderman: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        //physics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        self.physicsWorld.contactDelegate = self
        
        //setting background color
        let backgroundColor = SKColor(red: 42.0/255.0, green: 115.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        self.backgroundColor = backgroundColor
        
        //making a sun
        let sunColor = SKColor(red: 255.0/255.0, green: 244.0/255.0, blue: 48.0/255.0, alpha: 1.0) as SKColor
        let sunSize = CGSize(width: 50.0, height: 50.0)
        let sun = SKSpriteNode(color: sunColor, size: sunSize)
        
        sun.position = CGPoint(x: self.frame.width * 0.8, y: self.frame.height * 0.8)
        self.addChild(sun)
        
        // city image backgound
        // needs to fit better
        let cityTexture = SKTexture(imageNamed: "./pics/NYskyline.png")
        cityTexture.filteringMode = .nearest
       
        let cityBackground = SKSpriteNode(texture: cityTexture)
        cityBackground.position = CGPoint(x: 0.0, y: 0.0)
        cityBackground.zPosition = -1
        self.addChild(cityBackground)
        
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
        spiderman.position=CGPoint(x: self.frame.width * 0.2, y: self.frame.height * 0.3)
        
        spiderman.run(walking)
        
        spiderman.physicsBody = SKPhysicsBody(rectangleOf: spiderman.size)
        spiderman.physicsBody?.isDynamic = true
        spiderman.physicsBody?.allowsRotation = false
        
        spiderman.physicsBody?.categoryBitMask = personCategory
        spiderman.physicsBody?.collisionBitMask = cloudCategory
        spiderman.physicsBody?.contactTestBitMask = cloudCategory
        
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
        self.run(spawnAndRemoveForever)
        
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            spiderman.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            spiderman.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: self.frame.height * 0.25))
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
    }
}
