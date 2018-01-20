//
//  GameScene.swift
//  eatingClouds
//
//  Created by John Kuhn on 1/19/18.
//  Copyright © 2018 John Kuhn. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    override func didMove(to view: SKView) {
        //physics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.0)
        self.physicsWorld.contactDelegate = self
        
        //setting background color
        let backgroundColor = SKColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 1)
        self.backgroundColor = backgroundColor
        
        //draw a cloud
        let cloudTexture = SKTexture(imageNamed: "./clouds/cloud1.png")
        cloudTexture.filteringMode = .nearest
        
        let cloud = SKSpriteNode(texture: cloudTexture)
        cloud.position = CGPoint(x: 0.0, y: 0.0)
        
        self.addChild(cloud)
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}
