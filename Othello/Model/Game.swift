//
//  Game.swift
//  Othello
//
//  Created by Joonas Junttila on 20/04/2019.
//  Copyright © 2019 Joonas Junttila. All rights reserved.
//

import Foundation

class Game {
    var activePlayer: OthelloState
    let grid: OthelloGrid
    var winner = OthelloState.empty
    var score1 = 2
    var score2 = 2
    var changedTiles = [OthelloTile]()
    var previousLegalTiles = [OthelloTile]()
    
    init(x: Int, y: Int, firstPlayer: OthelloState) {
        self.activePlayer = firstPlayer
        self.grid = OthelloGrid.init(height: y, width: x)
    }
  
    // MARK: - Manipulating methods
    
    // alustaa pelitilanteen
    func startOver(){
        grid.initializeBoard()
        updateScore()
    }
    
    // vaihtaa pelivuoroa
    private func changeActivePlayer() {
        if activePlayer == .player1 { activePlayer = .player2 }
        else { activePlayer = .player1 }
    }
    
    // suorittaa siirron
    func makeAMove(forId id: Int) {
        
        // tarkistetaan, että ruutu on olemassa
        guard let tile = grid.getTile(forId: id) else { return }
        
        // tarkistetaan, että siirto on validi
        guard validateMove(tile) else { return }
        
        //suoritetaan siirto
        changedTiles = [OthelloTile]()
        changedTiles.append(tile)
        changedTiles.append(contentsOf: getTilesToBeUpdated(forTile: tile))
        
        // asetetaan löytyneet ruudut omiksi ruuduiksi
        for tile in changedTiles { tile.gameState = activePlayer }
        
        // päivitetään tilanne
        updateScore()
        previousLegalTiles = legalMoves()
        changeActivePlayer()
        
        // jos uudella pelaajalla ei ole mahdollisia siirtoja, vaihdetaan vuoro takaisin edelliselle
        if legalMoves().count == 0 { changeActivePlayer() }
    }
    
    // apumetodi: palauttaa kaikki ruudut, jotka muuttuvat siirron yhteydessä aktiivisen pelaajan ruuduiksi
    private func getTilesToBeUpdated(forTile tile: OthelloTile) -> [OthelloTile] {
        
        var result = [OthelloTile]()
        
        for direction in Directions.values {
            
            let widthChange = direction[0]
            let heightChange = direction[1]
            var x = tile.x + widthChange
            var y = tile.y + heightChange
            
            // tarkistetaan, että suunnassa on ainakin yksi ruutu, ja se on vastustajan
            guard let firstNeighbour = grid.getTile(forX: x, forY: y) else { continue }
            guard firstNeighbour.gameState != activePlayer, firstNeighbour.gameState != .empty else { continue }
            
            // lisätään ensimmäinen naapuri päivitettäväksi
            var tempTiles = [OthelloTile]()
            tempTiles.append(firstNeighbour)
            
            while true {
                
                // seuraava ruutu
                x += widthChange
                y += heightChange
                guard let nextNeighbour = grid.getTile(forX: x, forY: y) else { break }
                    
                // jos löytyy tyhjä ruutu, ei päivitettävää ole
                guard nextNeighbour.gameState != .empty else { break }
                    
                // jos ruutu on vastustajan, lisätään se päivitettäväksi
                if nextNeighbour.gameState == firstNeighbour.gameState {
                    tempTiles.append(nextNeighbour)
                    continue
                }
                    
                // jos ruutu on oma, lisätään välistä löytyneet vastustajan nappulat päivitettäviksi
                if nextNeighbour.gameState == activePlayer {
                    result.append(contentsOf: tempTiles)
                    break
                }
            }
        }
        
        return result
    }
    
    // päivittää pistetilanteen
    private func updateScore(){
        score1 = grid.tiles.filter({ $0.gameState == .player1 }).count
        score2 = grid.tiles.filter({ $0.gameState == .player2 }).count
    }
    
    // MARK: - Checks and validations
    
    // true, jos siirto voidaan tehdä
    private func validateMove(_ tile: OthelloTile) -> Bool {
        
        // tarkistetaan, että ruutu on vapaa
        guard tile.gameState == .empty else {
            print("Ruutu on jo pelattu: \(tile.gameState)")
            return false
        }
        
        // tarkistetaan että siirto on sallittu
        guard legalMoves().contains(where: { $0.id == tile.id }) else {
            print("Siirto \(tile.id) ei ole laillinen")
            return false
        }
        
        // tarkistetaan, että peli ei ole päättynyt
        guard !checkForWin() else {
            print("Peli on jo päättynyt. Voittaja oli \(winner)")
            return false
        }
        
        // tarkistetaan, että pelaajien yhteispisteet eivät ylitä pelilaudan kokoa
        let turnsPlayed = score1 + score2
        guard turnsPlayed < grid.size() else {
            print("Vuoroja pelattu \(turnsPlayed) vaikka ruutuja on vain \(grid.size())")
            return false
        }
        
        // Siirto ok
        return true
    }
    
    // true, jos peli on päättynyt
    private func checkForWin() -> Bool {
        
        if score1 == 0 {
            winner = .player2
            return true
        }
        
        if score2 == 0 {
            winner = .player1
            return true
        }
        
        // peli on kesken, jos ruudukko ei ole täynnä
        if score1 + score2 < grid.size() { return false }
        
        // pelin lopputulos: voitto tai tasapeli
        if score1 > score2 { winner = .player1 }
        else if score2 > score1 { winner = .player2 }
        else { winner = .empty }
        return true
    }
    
    // MARK: - Helper and utility methods
    
    // kaikki sallitut siirrot kyseisellä hetkellä
    func legalMoves() -> [OthelloTile] {
        
        var legalTiles = [OthelloTile]()
        let playerTiles = grid.tiles.filter { $0.gameState == activePlayer }
        
        for tile in playerTiles {
            for direction in Directions.values {
                
                // jos suunnasta löytyi sallittu siirto, lisätään se listaan
                if let legalTile = nextLegalTile(fromTile: tile, forDirection: direction) {
                    legalTiles.append(legalTile)
                }
            }
        }
        
        return legalTiles
    }

    // apumetodi: palauttaa sallitun siirron tietyssä suunnassa tai nil, mikäli sellaista ei ole
    private func nextLegalTile(fromTile tile: OthelloTile, forDirection direction: [Int]) -> OthelloTile? {
        
        let widthChange = direction[0]
        let heightChange = direction[1]
        var x = tile.x + widthChange
        var y = tile.y + heightChange
        
        guard let firstNeighbour = grid.getTile(forX: x, forY: y) else {
            // suunnasta ei löydy ruutuja
            return nil
        }
        
        // ensimmäinen naapuri ei saa olla tyhjä tai oma
        guard firstNeighbour.gameState != tile.gameState, firstNeighbour.gameState != .empty else { return nil }
        
        while true {
            
            // otetaan käsittelyyn seuraava ruutu
            x += widthChange
            y += heightChange
            guard let nextNeighbour = grid.getTile(forX: x, forY: y) else { break }
            
            // ruutu ei saa olla oma
            guard nextNeighbour.gameState != tile.gameState else { break }
            
            // palautetaan sallittu ruutu
            if nextNeighbour.gameState == .empty { return nextNeighbour }
        }
        
        // suunnasta ei löytynyt valideja siirtoja
        return nil
    }
    
    func playComputerTurn(){
        var moveToMake: OthelloTile?
        let w = grid.width
        let h = grid.height
        
        // Kulmapaikat
        let cornerTiles = [[1, 1], [1, h], [w, 1], [w, h]]
        
        // Kulmaa ympäröivä 3x3
        let goodTiles = [[3, 1], [3, 2], [3, 3], [2, 3], [1, 3],
                         [w-2, 1], [w-2, 2], [w-2, 3], [w-1, 3], [w, 3],
                         [1, h-2], [2, h-2], [3, h-2], [3, h-1], [3, h],
                         [w-2, h], [w-2, h-1], [w-2, h-2], [w-1, h-2], [w, h-2]]
        
        // Kulman viereiset ruudut
        let badTiles = [[1, 2], [2, 1],
                        [w-1, 1], [w, 2],
                        [1, h-1], [2, h],
                        [w-1, h], [w, h-1]]
        
        // Kulman kulmassa kiinni olevat ruudut
        let theWorstTiles = [[2,2], [w-1, 2], [2, h-1], [w-1, h-1]]
        
        let validMoves = legalMoves()
        
        var smallestAmountOfEnemyTilesAffected = grid.size()
        var largestAmountOfEnemyTilesAffected = 0
        var movesLeft = validMoves.count
        var i = 1
        
        for tile in validMoves {
            
            // Pidetään kirjaa siitä, montako siirtoa on valittavissa tämän jälkeen
            movesLeft -= 1
            i += 1
            
            // Jos siirtoa ei ole vielä valittu eikä muita ole jäljellä, valitaan siirto
            if moveToMake == nil && movesLeft == 0 {
                print("AI: Siirtoja oli vain yksi jäljellä: \(tile.x), \(tile.y)")
                moveToMake = tile
                break
            }
            
            // Jos kulmaruutu on pelattavissa, valitaan se
            if cornerTiles.contains([tile.x, tile.y]) {
                print("AI: Vallattiin kulmapaikka: \(tile.x), \(tile.y)")
                moveToMake = tile
                break
            }
            
            // Jos on tarjolla reunapaikka, mutta ei kulman vierestä, otetaan se
            if !badTiles.contains([tile.x, tile.y]) && (tile.x == 1 || tile.x == w || tile.y == 1 || tile.y == h) {
                print("AI: Vallattiin reunapaikka: \(tile.x), \(tile.y)")
                moveToMake = tile
                break
            }
            
            // Jos jokin muu hyvä ruutu on pelattavissa, valitaan se
            if goodTiles.contains([tile.x, tile.y]) {
                print("AI: Pelattiin siirto: \(tile.x), \(tile.y)")
                moveToMake = tile
                break
            }
            
            // Skipataan surkeat siirrot aina, mikäli muita vaihtoehtoja on vielä
            if theWorstTiles.contains([tile.x, tile.y]) {
                print("AI: Ei tarjottu kulmaa pelaajalle")
                continue
            }
            
            // Skipataan myös huonot siirrot aina, mikäli muita vaihtoehtoja on vielä
            if badTiles.contains([tile.x, tile.y]) {
                print("AI: Vältettiin huono siirto")
                continue
            }
            
            let affectedTiles = getTilesToBeUpdated(forTile: tile)
            
            // Voidaan valita vähiten nappuloita kääntävä siirto
            if smallestAmountOfEnemyTilesAffected > affectedTiles.count {
                smallestAmountOfEnemyTilesAffected = affectedTiles.count
                moveToMake = tile
            }
            
            // Voidaan valita eniten nappuloita kääntävä siirto
            else if largestAmountOfEnemyTilesAffected < affectedTiles.count {
                largestAmountOfEnemyTilesAffected = affectedTiles.count
//                moveToMake = tile
            }
        }
    
        guard let id = moveToMake?.id else {
            print("Unable to play computer turn.")
            activePlayer = .player1
            return
        }
        
        // Pelataan valittu siirto
        makeAMove(forId: id)
    }
}


