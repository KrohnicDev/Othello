//
//  OthelloTile.swift
//  Othello
//
//  Created by Joonas Junttila on 20/04/2019.
//  Copyright © 2019 Joonas Junttila. All rights reserved.
//

import Foundation
import UIKit

class OthelloTile {
    var gameState: OthelloState
    let x: Int
    let y: Int
    let id: Int
    
   
    init(xPosition: Int, yPosition: Int, id: Int) {
        x = xPosition
        y = yPosition
        gameState = .empty
        self.id = id
    }
    
    init(xPosition: Int, yPosition: Int, state: OthelloState, index: Int) {
        x = xPosition
        y = yPosition
        gameState = state
        self.id = index
    }
}


