//
//  GameScene.swift
//  test1
//
//  Created by Bilal Qaiser on 05/02/2018.
//  Copyright © 2018 Bilal Qaiser. All rights reserved.
//


import SpriteKit

class GameScene: SKScene {
    
    let bird = SKSpriteNode(imageNamed: "bird1")
    let flip = SKSpriteNode(imageNamed: "flip2")

    let gun1 = SKSpriteNode(imageNamed: "gun1")
    let gun2 = SKSpriteNode(imageNamed: "gun2")
    let bullet = SKSpriteNode(imageNamed: "bullet")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var fireRate:TimeInterval = 0.5
    var lastTime:TimeInterval = 0
    var gameOver = false

    let birdMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let birdAnimation: SKAction
    let birdAnimation2: SKAction

    let birdCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "bird.wav", waitForCompletion: false)
    var invincible = false
    let livesLabel = SKLabelNode(fontNamed: "Chalkduster")
    let livesLabel2 = SKLabelNode(fontNamed: "Chalkduster")
    let livesLabel3 = SKLabelNode(fontNamed: "Chalkduster")
    var lives = 0

    var totalSeconds:Int = 20
    var counter:Int = 10


    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width / maxAspectRatio,
                              height: playableHeight)
        
        var textures:[SKTexture] = []
        for i in 1...3 {
            textures.append(SKTexture(imageNamed: "bird\(i)"))
        }
        var textures2:[SKTexture] = []
        // 2
        for i in 1...3 {
            textures2.append(SKTexture(imageNamed: "flip\(i)"))
        }
        
        birdAnimation = SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
        
        birdAnimation2 = SKAction.animate(with: textures2,
                                         timePerFrame: 0.1)
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    override func didMove(to view: SKView) {
                restartTimer()
        livesLabel.text = "Bird Die: X"
        livesLabel.fontColor = SKColor.black
        livesLabel.fontSize = 75
        livesLabel.zPosition = 150
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(x: playableRect.size.width/2 + CGFloat(20), y: playableRect.size.height/2 - CGFloat(100))
        addChild(livesLabel)
        
        livesLabel2.text = "Seconds: X"
        livesLabel2.fontColor = SKColor.black
        livesLabel2.fontSize = 75
        livesLabel2.zPosition = 150
        livesLabel2.horizontalAlignmentMode = .right
        livesLabel2.verticalAlignmentMode = .top
        livesLabel2.position = CGPoint(x: playableRect.size.width/2 + CGFloat(20), y: playableRect.size.height/2 - CGFloat(100))
        addChild(livesLabel2)
        
        livesLabel3.text = "Bullet: 10"
        livesLabel3.fontColor = SKColor.black
        livesLabel3.fontSize = 75
        livesLabel3.zPosition = 150
        livesLabel3.horizontalAlignmentMode = .right
        livesLabel3.verticalAlignmentMode = .top
        livesLabel3.position = CGPoint(x: 2000, y: 476)
        addChild(livesLabel3)
        
        playBackgroundMusic(filename: "background.wav")
        
        
        backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "background1")
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        
        gun1.position = CGPoint(x: 1000, y:400)
        addChild(gun1)
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemy()
                },
                               SKAction.wait(forDuration: 1.0)])))

        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemy2()
                },
                               SKAction.wait(forDuration: 3.0)])))
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        func move(sprite: SKSpriteNode, velocity: CGPoint) {
            let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                       y: velocity.y * CGFloat(dt))
            sprite.position += amountToMove
        }
        
        livesLabel.text = "Bird die: \(lives)"
        
        if lives >= 8 && !gameOver {
            gameOver = true
            print("You win!")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
        livesLabel2.text = "Seconds: \(totalSeconds)"
        livesLabel3.text = "Bullet: \(counter)"
        checkCollisions()
    
        if totalSeconds == 6 {
            let blinkTimes = 10.0
            let duration = 5.0
            let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
                let slice = duration / blinkTimes
                let remainder = Double(elapsedTime).truncatingRemainder(
                    dividingBy: slice)
                node.isHidden = remainder > slice / 2
            }
            livesLabel2.fontColor = SKColor.red
            let setHidden = SKAction.run() { [weak self] in
                self?.livesLabel2.isHidden = false
                self?.invincible = false
            }
            self.run(SKAction.playSoundFileNamed("warning", waitForCompletion: false))
            livesLabel2.run(SKAction.sequence([blinkAction, setHidden]))

        }
        
        
        if counter == 6 {
            let blinkTimes = 10.0
            let duration = 5.0
            let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
                let slice = duration / blinkTimes
                let remainder = Double(elapsedTime).truncatingRemainder(
                    dividingBy: slice)
                node.isHidden = remainder > slice / 2
            }
            livesLabel3.fontColor = SKColor.red
            let setHidden = SKAction.run() { [weak self] in
                self?.livesLabel3.isHidden = false
                self?.invincible = false
            }
            self.run(SKAction.playSoundFileNamed("warning", waitForCompletion: false))
            livesLabel3.run(SKAction.sequence([blinkAction, setHidden]))
        }
        
        
        if totalSeconds == 1 || counter == 1 {
            gameOver = true
            print("You lose!")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                   y: velocity.y * CGFloat(dt))
        sprite.position += amountToMove
    }
  
    
    func spawnEnemy() {

        let bird = SKSpriteNode(imageNamed: "bird1")
        bird.run(SKAction.repeatForever(birdAnimation))
        bird.name = "bird1"

        bird.position = CGPoint(
            x: 0,
            y: size.height - 336)
        
        addChild(bird)

        let actionMove =
            SKAction.moveTo(x: size.width, duration: 1.0)
        let actionRemove = SKAction.removeFromParent()
        bird.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func spawnEnemy2() {
        
        let bird = SKSpriteNode(imageNamed: "flip1")
        bird.run(SKAction.repeatForever(birdAnimation2))
        bird.name = "flip"
        
        bird.position = CGPoint(
            x: size.width,
            y: size.height - 400)
        
        addChild(bird)
        
        let actionMove =
            SKAction.moveTo(x: -size.width, duration: 3.0)
        let actionRemove = SKAction.removeFromParent()
        bird.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gun1.removeFromParent()
        gun2.position = CGPoint(x: 1000, y:410)
        self.addChild(gun2)
        
        self.run(SKAction.wait(forDuration: 0.1)) {
            self.gun2.removeFromParent()

        }
        shoot()
        addChild(gun1)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        counter-=1
        print(counter)
    }
    
    
    
    func shoot(){
        
        self.run(SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false))
        let shoot = SKSpriteNode(imageNamed: "bullet")
        shoot.name = "shoot"
        shoot.position = gun1.position
        shoot.position.y += 1
        self.addChild(shoot)
        
        let animationDuration:TimeInterval = 0.3
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: gun1.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        shoot.run(SKAction.sequence(actionArray))
    }


    
    func birdHit(enemy: SKSpriteNode) {
        self.enumerateChildNodes(withName: "bird1") { node, _ in
            let bird = node as! SKSpriteNode
            bird.removeFromParent()
            self.run(self.birdCollisionSound)
        }
        lives += 1
        counter += 1
    }
    
    func birdHit2(enemy2: SKSpriteNode) {
        self.enumerateChildNodes(withName: "flip") { node, _ in
            let bird = node as! SKSpriteNode
            bird.removeFromParent()
            self.run(self.birdCollisionSound)
        }
        lives += 1
        counter += 1
    }
    
    
    func checkCollisions() {

        var hitEnemies: [SKSpriteNode] = []
        var hitEnemies2: [SKSpriteNode] = []

        enumerateChildNodes(withName: "shoot") { node, _ in
            let shoot = node as! SKSpriteNode
            self.enumerateChildNodes(withName: "bird1") { node, _ in
                let bird = node as! SKSpriteNode
            if shoot.frame.intersects(bird.frame) {
                hitEnemies.append(shoot)
            }
        }
    }
        for shoot in hitEnemies {
            birdHit(enemy: shoot)
        }
        
        
        enumerateChildNodes(withName: "shoot") { node, _ in
            let shoot2 = node as! SKSpriteNode
            self.enumerateChildNodes(withName: "flip") { node, _ in
                let bird = node as! SKSpriteNode
                if shoot2.frame.intersects(bird.frame) {
                    hitEnemies2.append(shoot2)
                }
            }
        }
        for shoot2 in hitEnemies2 {
            birdHit2(enemy2: shoot2)
        }
    }
    

    func restartTimer(){
        
        let wait:SKAction = SKAction.wait(forDuration: 1)
        let finishTimer:SKAction = SKAction.run {
            
            self.totalSeconds -= 1
            self.restartTimer()
        }
        let seq:SKAction = SKAction.sequence([wait, finishTimer])
        self.run(seq)
    }
}


