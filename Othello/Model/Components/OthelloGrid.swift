//
//  OthelloGrid.swift
//  Othello
//
//  Created by Joonas Junttila on 20/04/2019.
//  Copyright © 2019 Joonas Junttila. All rights reserved.
//

import Foundation

class OthelloGrid {
    let height: Int
    let width: Int
    let tiles: [OthelloTile]
    
    init(height: Int, width: Int) {
        
        // Tarkistetaan, että luvut ovat parilliset
        guard height % 2 == 0, width % 2 == 0 else {
            fatalError("Leveys \(width) ja pituus \(height) täytyy olla parilliset.")
        }
        
        var tempTiles = [OthelloTile]()
        var id = 1
        
        for y in 1...height {
            for x in 1...width {
                let tile = OthelloTile(xPosition: x, yPosition: y, id: id)
                tempTiles.append(tile)
                id += 1
            }
        }
        
        self.height = height
        self.width = width
        self.tiles = tempTiles
        initializeBoard()
    }
    
    func getTile(forX x: Int, forY y: Int) -> OthelloTile? {
        return tiles.first { $0.x == x && $0.y == y }
    }
    
    func getTile(forId id: Int) -> OthelloTile? {
        return tiles.first { $0.id == id }
    }
    
    func size() -> Int {
        return tiles.count
    }
    
    func initializeBoard(){
        // Nollataan kaikki ruudut
        for tile in tiles { tile.gameState = .empty }
        
        // Asetetaan alkutilanne
        let x = width/2
        let y = height/2
        getTile(forX: x, forY: y)?.gameState = .player1
        getTile(forX: x+1, forY: y)?.gameState = .player2
        getTile(forX: x, forY: y+1)?.gameState = .player2
        getTile(forX: x+1, forY: y+1)?.gameState = .player1
    }
    
}
