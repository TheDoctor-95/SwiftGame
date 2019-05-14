//
//  GameScene.swift
//  Game
//
//  Created by Pau Duran on 13/5/19.
//  Copyright © 2019 Pau Duran. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var cam: SKCameraNode?
    
    
    
    
    //Variables de Sprites
    var character: Character = Character()
    var enemies = [Character]()
    
    
    //Variables de rondas
    var rondaActual = 1
    let RONDA_AUGMENTO_DIFICULTAD = 3
    var points = 0
    
    //UI VARIABLES
    let labelVida = SKLabelNode()
    let labelGameOver = SKLabelNode()
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.physicsWorld.contactDelegate = self
        
        cam = SKCameraNode()
        self.camera = cam
        
        
        
        self.addChild(cam!)
        
        restart()
        
    }
    
    
    func restart() {
        self.removeAllChildren()
        enemies = [Character]()
        createPlayer()
        createEnemies()
        ponerVida()
        ponerGameOver()
    }
    
    
    enum tipoNodo: UInt32 {
        case character = 1
        case enemy = 2
    }
    
    
    func loadTextures(name: String, min: Int, max: Int)->[SKTexture]{
        var arrayTextures = [SKTexture]()
        
        for index in min...max{
            let textura = SKTexture(image: UIImage(named: "\(name)\(index)")!)
            
            arrayTextures.append(textura)
        }
        
        return arrayTextures
    }
    
    
    
    func createPlayer(){
        let arrayTextures = loadTextures(name: "archer",min:16,max:18)
        
        let sprite = SKSpriteNode(texture: arrayTextures[0])
        
        let animation = SKAction.repeatForever(SKAction.animate(with: arrayTextures, timePerFrame: 0.2))
        
        sprite.run(animation)
        
        sprite.position = CGPoint(x: 0, y: 0)
        
        sprite.setScale(4)
        
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: arrayTextures[0].size().height*2)
        
        sprite.physicsBody?.isDynamic = true
        
        sprite.physicsBody!.categoryBitMask = tipoNodo.character.rawValue
        
        sprite.physicsBody!.collisionBitMask = tipoNodo.enemy.rawValue
        sprite.physicsBody!.contactTestBitMask = tipoNodo.enemy.rawValue
        
        sprite.zPosition = 3
        self.addChild(sprite)
        
        character = Character(sprite: sprite, life: 100, atack: 40, moveDistance: 500)
        
    }
    
    func createEnemies(){
        let dificultad:Int = 5*((rondaActual/RONDA_AUGMENTO_DIFICULTAD)+1)
        for _ in 1...dificultad{
            let arrayTextures = loadTextures(name: "golem", min: 16, max: 18)
            let sprite = SKSpriteNode(texture: arrayTextures[0])
            
            let animation = SKAction.repeatForever(SKAction.animate(with: arrayTextures, timePerFrame: 0.2))
            sprite.name = "enemy"
            
            sprite.run(animation)
            
            sprite.position = CGPoint(x:0, y:50)
            
            sprite.setScale(4)
            
            
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: arrayTextures[0].size().height*2)
            
            sprite.physicsBody?.isDynamic = true
            
            sprite.physicsBody!.categoryBitMask = tipoNodo.enemy.rawValue
            
            sprite.physicsBody!.collisionBitMask = tipoNodo.character.rawValue | tipoNodo.enemy.rawValue
            sprite.physicsBody!.contactTestBitMask = tipoNodo.character.rawValue | tipoNodo.enemy.rawValue
            
            sprite.zPosition = 2
            
            self.addChild(sprite)
            let enemyCharracter = Character(sprite: sprite, life: 60, atack: 10, moveDistance: 500)
            enemies.append(enemyCharracter)
        }
        
    }
    
    func ponerVida(){
        labelVida.fontName = "Arial"
        labelVida.fontSize = 20
        labelVida.text = "0"
        labelVida.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 500)
        labelVida.zPosition = 4
        self.addChild(labelVida)
    }
    
    func ponerGameOver(){
        labelGameOver.fontName = "Arial"
        labelGameOver.fontSize = 80
        labelGameOver.text = "TRY"
        labelGameOver.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 500)
        labelGameOver.zPosition = 5
        labelGameOver.color = UIColor.red
        self.addChild(labelGameOver)
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
        if(character.life>0){
            let nodes = self.nodes(at: pos)
            
            if(nodes.count == 0){
                move(pos: pos)
            }else{
                if(distance(a: pos, b: character.sprite.position) < 200 && nodes[0].name == "enemy"){
                    let arrayAnimacion = loadTextures(name: "archer", min: 10, max: 15)
                    self.removeChildren(in: [nodes[0]])
                    //enemies.removeAll(where: enemy.sprite=node[0])
                    points += rondaActual
                    character.sprite.run(SKAction.animate(with: arrayAnimacion, timePerFrame: 0.2))
                }else{
                    move(pos: pos)
                }
            }
            
        }else{
            restart()
        }
        
        
    }
    
    func move(pos: CGPoint){
        let moveTo = SKAction.move(to: pos, duration: 1)
        character.sprite.run(moveTo) {
            self.moveEnemies()
        }
    }
    
    func moveEnemies() {
        for enemy in enemies{
            let dist = distance(a: enemy.sprite.position, b: character.sprite.position)
            var action: SKAction = SKAction.init()
            if(dist < 200){
                //ACATACA
                let arrayAnimacion = loadTextures(name: "golem", min: 10, max: 15)
                character.hit(damage: enemy.atack);
                action = SKAction.animate(with: arrayAnimacion, timePerFrame: 0.2)
                
            }else if(dist < 500) {
                //SE MUEVE HACIE EL PERSONAJE
                action = SKAction.move(to: character.sprite.position, duration: 1)
                
            }else {
                //SE MUEVE RANDOM
                
                
            }
            
            enemy.sprite.run(action, withKey: "movement");
            
        }
    }
    
    
    func distance(a: CGPoint, b: CGPoint) -> CGFloat{
        let xDist: CGFloat = a.x-b.x
        
        let yDist:CGFloat = a.y-b.y
        
        return sqrt((xDist*xDist)+(yDist*yDist))
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        super.update(currentTime)
        if let camera = cam{
            camera.position = character.sprite.position
        }
        
        labelVida.text = "\(character.life) -  \(character.maxLife) Enemies: \(enemies.count) Round: \(rondaActual) Points:\(points)"
        labelVida.position = character.sprite.position
        labelVida.position.y += 500
        
        if(enemies.count==0){
            rondaActual+=1
            createEnemies()
        }
        
        if(character.life <= 0){
            labelGameOver.position = character.sprite.position
            labelGameOver.text = "HAS PERDIDO! CLICA EN LA PANTALLA PARA VOLVER A EMPEZAR"
            
        }else{
            labelGameOver.text=""
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // en contact tenemos bodyA y bodyB que son los cuerpos que hicieron contacto
        let cuerpoA = contact.bodyA
        let cuerpoB = contact.bodyB
        // Miramos si la mosca ha pasado por el hueco
        print("contacto", cuerpoA.categoryBitMask, cuerpoB.categoryBitMask)
        
        let colisionador = enemies.first { (enemy) -> Bool in
            return enemy.sprite.physicsBody == cuerpoB
        }
        
        colisionador?.sprite.removeAction(forKey: "movement")
        
    }
    
}
