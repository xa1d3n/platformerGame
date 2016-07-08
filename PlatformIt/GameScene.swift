//
//  GameScene.swift
//  PlatformIt
//
//  Created by Aldin Fajic on 7/7/16.
//  Copyright (c) 2016 Aldin Fajic. All rights reserved.
//

import SpriteKit

struct CollisionNames {
    static let Player : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Coin : UInt32 = 0x1 << 4
}

class GameScene: SKScene {
    
    let Map = JSTileMap(named: "level1.tmx")
    var Player = SKSpriteNode()
    
    var movingLeft = Bool()
    var movingRight = Bool()
    
    var cam = SKCameraNode()
    
    override func didMoveToView(view: SKView) {
        Map.position = CGPoint(x: 0, y: 0)
        self.addChild(Map)
        
        self.camera = cam
        self.addChild(cam)
        // center camera on screen
        cam.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2)
        
        Player = SKSpriteNode(imageNamed: "player")
        Player.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        Player.size = CGSize(width: 30, height: 45)
        
        // SET physics
        // size of physics body
        Player.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: Player.size.width, height: Player.size.height))
        // the phsyics body
        Player.physicsBody?.categoryBitMask = CollisionNames.Player
        // physics body colliding with
        Player.physicsBody?.collisionBitMask = CollisionNames.Ground | CollisionNames.Coin
        Player.physicsBody?.contactTestBitMask = CollisionNames.Ground | CollisionNames.Coin
        Player.physicsBody?.affectedByGravity = true
        
        self.addChild(Player)
        
        
        // Physics for ground
        // reference ground object in .tmx file
        let groundGroup : TMXObjectGroup = self.Map.groupNamed("GroundObjects")
        // iterate over the ground objects
        for i in 0..<groundGroup.objects.count {
            let groundObject = groundGroup.objects.objectAtIndex(i) as! NSDictionary
            // get widht and height of object
            guard let width = groundObject.objectForKey("width") as? String else { continue }
            //let width = groundObject.objectForKey("width") as! String
            let height = groundObject.objectForKey("height") as! String
            
            let wallSize = CGSize(width: Int(width)!, height: Int(height)!)
            
            // create the sprite object
            let groundSprite = SKSpriteNode(color: UIColor.clearColor(), size: wallSize)
            
            // get the position of the ground object
            let x = groundObject.objectForKey("x") as! Int
            let y = groundObject.objectForKey("y") as! Int
            
            // set position
            groundSprite.position = CGPoint(x: x + Int(groundGroup.positionOffset.x) + Int(width)! / 2, y: y + Int(groundGroup.positionOffset.y) + Int(height)! / 2)
            
            // set physics
            groundSprite.physicsBody = SKPhysicsBody(rectangleOfSize: wallSize)
            groundSprite.physicsBody?.categoryBitMask = CollisionNames.Ground
            groundSprite.physicsBody?.collisionBitMask = CollisionNames.Player
            groundSprite.physicsBody?.contactTestBitMask = CollisionNames.Player
            
            groundSprite.physicsBody?.affectedByGravity = false
            // nothing happens if touched by something else
            groundSprite.physicsBody?.dynamic = false
            self.addChild(groundSprite)
            
        }
    }
    
    // detect touch direction
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if location.x >= Player.position.x {
                movingLeft = true
            }
            else if location.x <= Player.position.x {
                movingRight = true
            }
        }
    }
    
    // cancel movement
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        movingRight = false
        movingLeft = false
    }
   
    override func update(currentTime: CFTimeInterval) {
        if movingLeft == true {
            // set limit to how fast player can move - move if less than 100
            if Player.physicsBody?.velocity.dx <= 100 {
                // move the player left
                Player.physicsBody?.applyForce(CGVector(dx: 100, dy: 0))
            } else {
                
            }
            
        }
        else if movingRight == true {
            if Player.physicsBody?.velocity.dx >= -100 {
                // move the player left
                Player.physicsBody?.applyForce(CGVector(dx: -100, dy: 0))
            } else {
                
            }
        }
        
        // don't go off left screen edge
        if Player.position.x >= self.frame.width / 2 {
            cam.position.x = Player.position.x
        }
    }
}
