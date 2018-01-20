//
//  GameScene.swift
//  eatingClouds
//
//  Created by John Kuhn on 1/19/18.
//  Copyright © 2018 John Kuhn. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // private var label : SKLabelNode?
    // private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        //physics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.0)
        self.physicsWorld.contactDelegate = self
        
        //setting background color
        let backgroundColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
        self.backgroundColor = backgroundColor
        
        //draw a cloud
        let cloudTexture = SKTexture(imageNamed: "cloud1")
        cloudTexture.filteringMode = .nearest
        
        let cloud = SKSpriteNode(texture: cloudTexture)
        cloud.position = CGPoint(x: self.frame.width * 0.3, y: self.frame.height * 0.5)
        
        self.addChild(cloud)
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}
