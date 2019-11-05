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
        self.grid.initializeBoard()
        self.updateScore()
    }
    
    // vaihtaa pelivuoroa
    private func changeActivePlayer() {
        if self.activePlayer == .player1 { self.activePlayer = .player2 }
        else { self.activePlayer = .player1 }
    }
    
    // suorittaa siirron
    func makeAMove(forId id: Int) {
        
        // tarkistetaan, että ruutu on olemassa
        guard let tile = self.grid.getTile(forId: id) else { return }
        
        // tarkistetaan, että siirto on validi
        guard self.validateMove(tile) else { return }
        
        //suoritetaan siirto
        var changedTiles = [OthelloTile]()
        changedTiles.append(tile)
        changedTiles.append(contentsOf: self.getTilesToBeUpdated(forTile: tile))
        changedTiles.forEach { $0.gameState = activePlayer }
        self.changedTiles = changedTiles
        
        // päivitetään tilanne
        self.updateScore()
        self.previousLegalTiles = legalMoves()
        self.changeActivePlayer()
        
        // jos uudella pelaajalla ei ole mahdollisia siirtoja, vaihdetaan vuoro takaisin edelliselle
        if self.legalMoves().count == 0 { self.changeActivePlayer() }
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
            guard let firstNeighbour = self.grid.getTile(forX: x, forY: y) else { continue }
            guard
                firstNeighbour.gameState != activePlayer,
                firstNeighbour.gameState != .empty
                else { continue }
            
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
        
        self.score1 = self.grid.tiles
            .filter({ $0.gameState == .player1 })
            .count
        
        self.score2 = self.grid.tiles
            .filter({ $0.gameState == .player2 })
            .count
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
        guard self.legalMoves().contains(where: { $0.id == tile.id }) else {
            print("Siirto \(tile.id) ei ole laillinen")
            return false
        }
        
        // tarkistetaan, että peli ei ole päättynyt
        guard !checkForWin() else {
            print("Peli on jo päättynyt. Voittaja oli \(winner)")
            return false
        }
        
        // tarkistetaan, että pelaajien yhteispisteet eivät ylitä pelilaudan kokoa
        let combinedScore = score1 + score2
        guard combinedScore < grid.size() else {
            print("Vuoroja pelattu \(combinedScore) vaikka ruutuja on vain \(self.grid.size())")
            return false
        }
        
        // Siirto ok
        return true
    }
    
    // true, jos peli on päättynyt
    private func checkForWin() -> Bool {
        var winner: OthelloState? = nil
        let score1 = self.score1
        let score2 = self.score2
        let combinedScore = score1 + score2
        let boardSize = self.grid.size()
        
        // peli voi päättyä vajaaseen lautaan vain jos toiselta loppuu nappulat
        if score1 == 0 {
            winner = .player2
        } else if score2 == 0 {
            winner = .player1
        } else if combinedScore < boardSize {
            // peli kesken
            return false
        }
        
        if winner == nil {
            if score1 > score2 {
                winner = .player1
            } else if score2 > score1 {
                winner = .player2
            } else {
                winner = .empty
            }
        }
        
        guard let declaredWinner = winner else { return false }
        
        self.winner = declaredWinner
        return true
    }
    
    // MARK: - Helper and utility methods
    
    // kaikki sallitut siirrot kyseisellä hetkellä
    func legalMoves() -> [OthelloTile] {
        
        var legalTiles = [OthelloTile]()
        let playerTiles = self.grid.tiles.filter { $0.gameState == self.activePlayer }
        
        for tile in playerTiles {
            for direction in Directions.values {
                
                // jos suunnasta löytyi sallittu siirto, lisätään se listaan
                if let legalTile = self.nextLegalTile(fromTile: tile, forDirection: direction) {
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
        
        // suunnasta pitää löytyä edes yksi ruutu
        guard let firstNeighbour = self.grid.getTile(forX: x, forY: y) else {
            return nil
        }
        
        // ensimmäinen naapuri täytyy olla vastustajan
        guard
            firstNeighbour.gameState != tile.gameState,
            firstNeighbour.gameState != .empty
            else { return nil }
        
        // käsitellään ruutuja kunnes sallittu siirto löytyy
        while true {
            
            // täytyy löytyä seuraava ruutu
            x += widthChange
            y += heightChange
            guard let nextNeighbour = self.grid.getTile(forX: x, forY: y) else { break }
            
            // ei saa olla oma
            guard nextNeighbour.gameState != tile.gameState else { break }
            
            // ensimmäinen tyhjä on sallittu ruutu
            if nextNeighbour.gameState == .empty { return nextNeighbour }
        }
        
        // suunnasta ei löytynyt valideja siirtoja
        return nil
    }
    
    func playComputerTurn(){
        var selectedMove: OthelloTile?
        let width = self.grid.width
        let height = self.grid.height
        
        // Kulmapaikat
        let cornerTiles = [[1, 1], [1, height], [width, 1], [width, height]]
        
        // Kulmaa ympäröivä 3x3
        let goodTiles = [[3, 1], [3, 2], [3, 3], [2, 3], [1, 3],
                         [width-2, 1], [width-2, 2], [width-2, 3], [width-1, 3], [width, 3],
                         [1, height-2], [2, height-2], [3, height-2], [3, height-1], [3, height],
                         [width-2, height], [width-2, height-1], [width-2, height-2], [width-1, height-2], [width, height-2]]
        
        // Kulman viereiset ruudut
        let badTiles = [[1, 2], [2, 1],
                        [width-1, 1], [width, 2],
                        [1, height-1], [2, height],
                        [width-1, height], [width, height-1]]
        
        // Kulman kulmassa kiinni olevat ruudut
        let theWorstTiles = [[2,2], [width-1, 2], [2, height-1], [width-1, height-1]]
        
        let validMoves = legalMoves()
        var minAmountOfEnemyTilesAffected = self.grid.size()
        var maxAmountOfEnemyTilesAffected = 0
        var movesLeft = validMoves.count
        
        for tile in validMoves {
            
            // Pidetään kirjaa siitä, montako siirtoa on valittavissa tämän siirron jälkeen
            movesLeft -= 1
            
            // Jos siirtoa ei ole vielä valittu eikä muita ole jäljellä, siirto on pakko tehdä
            if movesLeft == 0 && selectedMove == nil {
                print("AI: Siirtoja oli vain yksi jäljellä: \(tile.x), \(tile.y)")
                selectedMove = tile
                break
            }
            
            // Jos kulmaruutu on pelattavissa, valitaan se
            if cornerTiles.contains([tile.x, tile.y]) {
                print("AI: Vallattiin kulmapaikka: \(tile.x), \(tile.y)")
                selectedMove = tile
                break
            }
            
            // Jos on tarjolla reunapaikka, mutta ei kulman vierestä, otetaan se
            if !badTiles.contains([tile.x, tile.y]) && (tile.x == 1 || tile.x == width || tile.y == 1 || tile.y == height) {
                print("AI: Vallattiin reunapaikka: \(tile.x), \(tile.y)")
                selectedMove = tile
                break
            }
            
            // Jos jokin muu hyvä ruutu on pelattavissa, valitaan se
            if goodTiles.contains([tile.x, tile.y]) {
                print("AI: Pelattiin siirto: \(tile.x), \(tile.y)")
                selectedMove = tile
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
            
            let numberOfAffectedTiles = self.getTilesToBeUpdated(forTile: tile).count
            
            // Voidaan valita suurin tai pienin mahdollinen määrä käännettäviä nappuloita
            let computerPrefersMaximumImpact = true
            
            if numberOfAffectedTiles > maxAmountOfEnemyTilesAffected  {
                
                maxAmountOfEnemyTilesAffected = numberOfAffectedTiles
                
                if computerPrefersMaximumImpact {
                    selectedMove = tile
                    continue
                }
            }
            
            if numberOfAffectedTiles < minAmountOfEnemyTilesAffected {
                
                minAmountOfEnemyTilesAffected = numberOfAffectedTiles
                
                if !computerPrefersMaximumImpact {
                    selectedMove = tile
                    continue
                }
            }
        }
        
        guard let id = selectedMove?.id else {
            print("Unable to play computer turn.")
            self.activePlayer = .player1
            return
        }
        
        // Pelataan valittu siirto
        self.makeAMove(forId: id)
    }
}


