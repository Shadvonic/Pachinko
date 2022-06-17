//
//  GameScene.swift
//  Pachinko
//
//  Created by Marc Moxey on 6/13/22.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let availableBalls = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    
   
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            }
        }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var ballsLabel: SKLabelNode!
    
    var numBalls = 0 {
           didSet {
               ballsLabel.text = "Balls: \(numBalls)"
           }
       }
    
 override func didMove(to view: SKView) {
     
     let background = SKSpriteNode(imageNamed: "background") // create background
     background.position = CGPoint(x: 512, y: 384) // placed in middle of the screen
     background.blendMode = .replace // just draw ignore alpha
     background.zPosition = -1 // place it behind everything else
     addChild(background) // add to game scene
     scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
     scoreLabel.horizontalAlignmentMode = .right
     scoreLabel.position = CGPoint(x: 980, y: 700)
     addChild(scoreLabel)
     
     
     editLabel = SKLabelNode(fontNamed: "Chalkduster")
     editLabel.text = "Edit"
     editLabel.position = CGPoint(x: 80, y: 700)
     addChild(editLabel)
     
     
     ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
            ballsLabel.text = "Balls: 0"
            ballsLabel.horizontalAlignmentMode = .center
            ballsLabel.position = CGPoint(x: 512, y: 700)
            addChild(ballsLabel)
     
     physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
     
     
     physicsWorld.contactDelegate = self
    
     
     makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
     makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
     makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
     makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
     
     
     makeBouncer(at: CGPoint(x: 0, y: 0))
     makeBouncer(at: CGPoint(x: 256, y: 0))
     makeBouncer(at: CGPoint(x: 512, y: 0))
     makeBouncer(at: CGPoint(x: 768, y: 0))
     makeBouncer(at: CGPoint(x: 1024, y: 0))
     
     
     
     
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        guard let touch = touches.first else { return } // read the first touch
        
        
        
        let location = touch.location(in: self) // where the touch happen
        
        let object = nodes(at: location) // what nodes exist in our scene
        
        if object.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                let size = CGSize(width: Int.random(in: 16...128), height: 16) // make random size
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size) // make box with random colors
                box.zRotation = CGFloat.random(in: 0...3) // rotate randomly
                box.position = location
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false // don't allow to move
                addChild(box) // add to game scene
            } else {
                
                
                let ball = SKSpriteNode(imageNamed:availableBalls.randomElement() ?? "ballRed")
                
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0) // the ball behaves as balls
                ball.physicsBody?.restitution = 0.4 // bounce of the ball
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0 // which node should ball bump into, collision you want to know about
                ball.position = CGPoint(x: location.x, y: 650) // position at touch location
                ball.name = "ball"
                
                if numBalls > 5 {
                    if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                        fireParticles.position = location
                    }
                    return
                   
                }
              
                numBalls += 1
                addChild(ball) // add toe game screen
                
                
            }
            
        }

        
//        let box = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 64)) // create a box to see where the touch location happen on the screen
//        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64)) // give physics body matching size of the box itself
//        box.position = location // position at touch location
//        addChild(box) // add to game scene
        
        
    }
    
    
    func makeBouncer(at position: CGPoint) {
        
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false // collied with other object but wont move
        addChild(bouncer)
    }

    
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            
        } else if object.name == "bad" {
            destroy(ball: ball)
            if score > 0 {
                score -= 1
            }
        }
    }
    
    
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") { // create high performance particle effects
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
            
        ball.removeFromParent()
        
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" { // first body the ball
            collision(between: nodeA, object: nodeB) // call collision, a being the ball and b being the object of contact
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
}
