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
    static let Flag : UInt32 = 0x1 << 8
    static let Fireball : UInt32 = 0x1 << 16
    static let FlyingFireball :UInt32 = 0x1 << 20
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Map = JSTileMap()
    var Player = SKSpriteNode()
    
    var movingLeft = Bool()
    var movingRight = Bool()
    
    var cam = SKCameraNode()
    
    var bankValue = Int()
    
    var coinLbl = SKLabelNode()
    
    var flag = SKSpriteNode()
    
    var levelNumber = Int()
    
    // make the characer jump. by moving himp up
    func jump() {
        self.Player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
    }
    
    func addFlag() {
        let flagGroup : TMXObjectGroup = self.Map.groupNamed("EndObject")
        
        let flagObject = flagGroup.objectNamed("Flag") as NSDictionary
        
        let width = flagObject.objectForKey("width") as! String
        let height = flagObject.objectForKey("height") as! String
        
        // get size of flag
        let flagSize = CGSize(width: Int(width)!, height: Int(height)!)
        
        // create sprite object
        flag = SKSpriteNode(imageNamed: "flag")
        flag.size = flagSize
        
        // get position
        let x = flagObject.objectForKey("x") as! Int
        let y = flagObject.objectForKey("y") as! Int
        
        // set coin position
        flag.position = CGPoint(x: x + Int(flagGroup.positionOffset.x) + Int(width)! / 2, y: y + Int(flagGroup.positionOffset.y) + Int(height)! / 2)
        
        // set physics
        flag.physicsBody = SKPhysicsBody(rectangleOfSize: flagSize)
        flag.physicsBody?.affectedByGravity = false
        flag.physicsBody?.categoryBitMask = CollisionNames.Flag
        flag.physicsBody?.collisionBitMask = CollisionNames.Player
        flag.physicsBody?.contactTestBitMask = CollisionNames.Player
        
        self.addChild(flag)
    }
    
    func addCoins() {
        let coinGroup : TMXObjectGroup = self.Map.groupNamed("Coins")
        // iterate over coins
        for i in 0..<coinGroup.objects.count {
            let coinObject = coinGroup.objects.objectAtIndex(i) as! NSDictionary
            
            // coin width and height
            guard let width = coinObject.objectForKey("width") as? String else { continue }
            guard let height = coinObject.objectForKey("height") as? String else { continue }
            
            // get size of coin
            let coinSize = CGSize(width: Int(width)!, height: Int(height)!)
            // create sprite object
            let coinSprite = SKSpriteNode(imageNamed: "coin")
            coinSprite.size = coinSize
            
            // get position
            guard let x = coinObject.objectForKey("x") as? Int else { continue }
            guard let y = coinObject.objectForKey("y") as? Int else { continue }
            
            // set coin position
            coinSprite.position = CGPoint(x: x + Int(coinGroup.positionOffset.x) + Int(width)! / 2, y: y + Int(coinGroup.positionOffset.y) + Int(height)! / 2)
            
            // set physics
            coinSprite.physicsBody = SKPhysicsBody(rectangleOfSize: coinSize)
            coinSprite.physicsBody?.affectedByGravity = false
            coinSprite.physicsBody?.categoryBitMask = CollisionNames.Coin
            coinSprite.physicsBody?.collisionBitMask = CollisionNames.Player
            coinSprite.physicsBody?.contactTestBitMask = CollisionNames.Player
            
            self.addChild(coinSprite)
            
        }
    }
    
    func addGround() {
        // reference ground object in .tmx file
        let groundGroup : TMXObjectGroup = self.Map.groupNamed("GroundObjects")
        
        // iterate over the ground objects
        for i in 0..<groundGroup.objects.count {
            let groundObject = groundGroup.objects.objectAtIndex(i) as! NSDictionary
            // get widht and height of object
            guard let width = groundObject.objectForKey("width") as? String else { continue }
            guard let height = groundObject.objectForKey("height") as? String else { continue }
            
            let wallSize = CGSize(width: Int(width)!, height: Int(height)!)
            
            // create the sprite object
            let groundSprite = SKSpriteNode(color: UIColor.clearColor(), size: wallSize)
            
            // get the position of the ground object
            guard let x = groundObject.objectForKey("x") as? Int else { continue}
            guard let y = groundObject.objectForKey("y") as? Int else { continue}
            
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
    
    func addFireball() {
        let powerUpGroup : TMXObjectGroup = self.Map.groupNamed("PowerUps")
        
        for i in 0..<powerUpGroup.objects.count {
            let fireballObject = powerUpGroup.objectNamed("Fire") as NSDictionary
            
            let width = fireballObject.objectForKey("width") as! String
            let height = fireballObject.objectForKey("height") as! String
            
            // get size of flag
            let fireballSize = CGSize(width: Int(width)!, height: Int(height)!)
            
            // create sprite object
            let fireball = SKSpriteNode(imageNamed: "fireball")
            fireball.size = fireballSize
            
            // get position
            let x = fireballObject.objectForKey("x") as! Int
            let y = fireballObject.objectForKey("y") as! Int
            
            // set coin position
            fireball.position = CGPoint(x: x + Int(powerUpGroup.positionOffset.x) + Int(width)! / 2, y: y + Int(powerUpGroup.positionOffset.y) + Int(height)! / 2)
            
            // set physics
            fireball.physicsBody = SKPhysicsBody(rectangleOfSize: fireballSize)
            fireball.physicsBody?.affectedByGravity = false
            fireball.physicsBody?.categoryBitMask = CollisionNames.Fireball
            fireball.physicsBody?.collisionBitMask = CollisionNames.Player
            fireball.physicsBody?.contactTestBitMask = CollisionNames.Player
            
            self.Map.addChild(fireball)
        }

    }
    
    func setupLables() {
        coinLbl.text = "Coins: \(bankValue)"
        coinLbl.color = UIColor.yellowColor()
        coinLbl.fontColor = UIColor.yellowColor()
        coinLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 3)
        self.addChild(coinLbl)
    }
    
    func setupScene(scene: String) {
        setupLables()
        // save coins
        let userDefaults = NSUserDefaults()
        if userDefaults.integerForKey("bank") != 0 {
            bankValue = userDefaults.integerForKey("bank")
        } else {
            bankValue = 0
        }
        
        
        // remove all nodes
        for node in self.children {
            node.removeFromParent()
        }
        
        Map = JSTileMap(named: scene)
        Map.position = CGPoint(x: 0, y: 0)
        self.addChild(Map)
        
        // add up gesture recognizer to scene. Call jump function
        let gestureUp = UISwipeGestureRecognizer(target: self, action: #selector(jump))
        gestureUp.direction = .Up
        view!.addGestureRecognizer(gestureUp)
        
        self.physicsWorld.contactDelegate = self
        
        self.camera = cam
        self.addChild(cam)
        // center camera on screen
        cam.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2)
        
        Player = SKSpriteNode(imageNamed: "player")
        Player.position = CGPoint(x: self.frame.width / 2, y: 50)
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
        Player.physicsBody?.allowsRotation = false
        
        self.addChild(Player)
        
        addGround()
        addCoins()
        addFlag()
        addFireball()
    }
    
    
    override func didMoveToView(view: SKView) {
        // get last level
        let userDefaults = NSUserDefaults()
        
        if userDefaults.integerForKey("levelNumber") != 0 {
            levelNumber = userDefaults.integerForKey("levelNumber") 
            let currentLevel = "level\(levelNumber).tmx"
            setupScene(currentLevel)
        } else {
            setupScene("level1.tmx")
            levelNumber = 1
        }
    }
    
    // detect touch direction
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        shootFireballs()
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
            // update coin label position
            coinLbl.position.x = Player.position.x
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Player && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Coin {
            // remove the coin
            bodyB.node?.removeFromParent()
            bankValue += 1
            coinLbl.text = "Coins: \(bankValue)"
        }
        else if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Coin && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Player {
            bodyA.node?.removeFromParent()
            bankValue += 1
            coinLbl.text = "Coins: \(bankValue)"
            
            // set coins value
            
        }
        
        // handle flag collisions
        else if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Player && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Flag {
            changeLevels()
        }
        else if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Flag && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Player {
            changeLevels()
        }
        
        // handle fireball collision
        else if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Player && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Fireball {
            bodyB.node?.removeFromParent()
        }
        else if bodyA.node?.physicsBody?.categoryBitMask == CollisionNames.Fireball && bodyB.node?.physicsBody?.categoryBitMask == CollisionNames.Player {
            bodyA.node?.removeFromParent()
        }
    }
    
    func changeLevels() {
        levelNumber += 1
        let userDefaults = NSUserDefaults()
        userDefaults.setInteger(levelNumber, forKey: "levelNumber")
        let currentLevel = "level\(levelNumber).tmx"
        // save coins
        userDefaults.setInteger(bankValue, forKey: "bank")
        setupScene(currentLevel)
    }
    
    func shootFireballs() {
        let fireball = SKSpriteNode(imageNamed: "fireball")
        fireball.size = CGSize(width: 15, height: 15)
        fireball.position = Player.position
        
        fireball.physicsBody = SKPhysicsBody(circleOfRadius: fireball.size.width / 2)
        fireball.physicsBody?.affectedByGravity = true
        fireball.physicsBody?.friction = 0
        // set the bounciness
        fireball.physicsBody?.restitution = 0.8
        fireball.physicsBody?.categoryBitMask = CollisionNames.FlyingFireball
        // collide it with ground
        fireball.physicsBody?.collisionBitMask = CollisionNames.Ground
        fireball.physicsBody?.contactTestBitMask = CollisionNames.Ground
        
        self.addChild(fireball)
        
        // move it
        fireball.physicsBody?.applyImpulse(CGVector(dx: 2, dy: 2))
    }
}
