//
//  Character.swift
//  Game
//
//  Created by Pau Duran on 13/5/19.
//  Copyright © 2019 Pau Duran. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class Character {
    
    var sprite: SKSpriteNode
    var life: Int
    var maxLife: Int
    var atack: Int
    var moveDistance: Int
    
    init(){
        self.sprite = SKSpriteNode()
        self.life = 0
        self.maxLife = 0
        self.atack = 0
        self.moveDistance = 0
    }
    
    init(sprite: SKSpriteNode, life: Int, atack: Int, moveDistance: Int) {
        self.sprite = sprite
        self.life = life
        self.maxLife = life
        self.atack = atack
        self.moveDistance = moveDistance
        
    }
    
}
