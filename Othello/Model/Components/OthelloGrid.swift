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
        if height % 2 != 0 || width % 2 != 0 {
            fatalError("Leveys \(width) ja pituus \(height) täytyy olla parilliset.")
        }
        
        self.height = height
        self.width = width
        
        var tempTiles = [OthelloTile]()
        var id = 1
        for y in 1...height {
            for x in 1...width {
                let tile = OthelloTile.init(xPosition: x, yPosition: y, id: id)
                tempTiles.append(tile)
                id = id + 1
            }
        }
        
        self.tiles = tempTiles
        initializeBoard()
        
    }
    
    func getTile(forX x: Int, forY y: Int) -> OthelloTile? {
        for tile in tiles {
            if tile.x == x && tile.y == y {
                return tile
            }
        }
        return nil
    }
    
    func getTile(forId id: Int) -> OthelloTile? {
        for tile in tiles {
            if tile.id == id  {
                return tile
            }
        }
        print("getTile: Ruutua ei löytynyt id:llä \(id)")
        return nil
    }
    
    func size() -> Int {
        return tiles.count
    }
    
    func initializeBoard(){
        // Nollataan vanhat ruudut
        for tile in tiles {
            tile.gameState = .empty
        }
        
        // Asetetaan alkutilanne
        let x = width/2
        let y = height/2
        getTile(forX: x, forY: y)?.gameState = .player1
        getTile(forX: x+1, forY: y)?.gameState = .player2
        getTile(forX: x, forY: y+1)?.gameState = .player2
        getTile(forX: x+1, forY: y+1)?.gameState = .player1
    }
    
}
