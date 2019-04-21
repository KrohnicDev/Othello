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
        if activePlayer == .player1 {
            activePlayer = .player2
        } else {
            activePlayer = .player1
        }
    }
    
    // suorittaa siirron
    func makeAMove(forId id: Int) {
        
        guard let tile = grid.getTile(forId: id) else {
            // ruutua ei löydy
            return
        }
        
        // siirto ei ole validi
        if !validateMove(tile) { return }
        
        //suoritetaan siirto
        tile.gameState = activePlayer
        updateTiles(forTile: tile)
        
        // päivitetään tilanne
        updateScore()
        changeActivePlayer()
        
        // jos uudella pelaajalla ei ole mahdollisia siirtoja, vaihdetaan vuoro takaisin edelliselle
        if legalMoves().count == 0 {
            changeActivePlayer()
        }
    }
    
    // apumetodi: suorittaa siirron ja päivittää ympäröivät ruudut
    private func updateTiles(forTile tile: OthelloTile) {
        
        var tilesToBeChanged = [OthelloTile]()
        
        // käydään läpi kaikissa suunnissa olevat ruudut
        directions: for direction in Directions.values {
            let widthChange = direction[0]
            let heightChange = direction[1]
            var x = tile.x + widthChange
            var y = tile.y + heightChange
            
            guard let firstNeighbour = grid.getTile(forX: x, forY: y) else {
                // seuraava suunta
                continue
            }
            
            var tempTiles = [OthelloTile]()
            
            // ensimmäinen naapuri täytyy olla vastustajan
            if firstNeighbour.gameState == activePlayer || firstNeighbour.gameState == .empty {
                // seuraava suunta
                continue
            }
            
            tempTiles.append(firstNeighbour)
            
            neighbours: while true {
                x = x + widthChange
                y = y + heightChange
                
                guard let nextNeighbour = grid.getTile(forX: x, forY: y) else {
                    // seuraavaa ruutua ei ole
                    break neighbours
                }
                
                // käsitellään löytynyt ruutu
                switch nextNeighbour.gameState {
                    
                // jos ruutu on tyhjä, poistutaan ilman päivitystä
                case .empty: break neighbours
                    
                // jos ruutu on vastustajan, lisätään se päivitettävien listalle
                case firstNeighbour.gameState: tempTiles.append(nextNeighbour)
                    
                // jos sarja päättyy omaan ruutuun, lisätään välistä löytyneet vastustajan nappulat päivitettäviksi
                case activePlayer: tilesToBeChanged.append(contentsOf: tempTiles)
                
                default: break
                }
            }
        }
        
        // asetetaan löytyneet ruudut omiksi ruuduiksi
        for tile in tilesToBeChanged {
            tile.gameState = activePlayer
        }
    }
    
    // päivittää pistetilanteen
    private func updateScore(){
        score1 = 0
        score2 = 0
        
        for tile in grid.tiles {
            switch tile.gameState {
            case .empty: break
            case .player1: score1 = score1 + 1
            case .player2: score2 = score2 + 1
            }
        }
    }
    
    // MARK: - Checks and validations
    
    // true, jos siirto voidaan tehdä
    private func validateMove(_ tile: OthelloTile) -> Bool {
        
        // tarkistetaan, että ruutu on vapaa
        if tile.gameState != .empty {
            print("Ruutu on jo pelattu: \(tile.gameState)")
            return false
        }
        
        // tarkistetaan onko siirto laillinen
        if !legalMoves().contains(where: { (legalTile) -> Bool in
            tile.id == legalTile.id
        }) {
            print("Siirto \(tile.id) ei ole laillinen")
            return false
        }
        
        // tarkistetaan, että pelaajien yhteispisteet eivät ylitä pelilaudan kokoa
        let turnsPlayed = score1 + score2
        if  turnsPlayed >= grid.size() {
            print("Vuoroja pelattu \(turnsPlayed) vaikka ruutuja on vain \(grid.size())")
            return false
        }
        
        // tarkistetaan, että peli ei ole päättynyt
        if checkForWin() {
            print("Peli on jo päättynyt. Voittaja oli \(winner)")
            return false
        }
        
        // Siirto ok
        return true
    }
    
    // true, jos peli on päättynyt
    private func checkForWin() -> Bool {
        
        // jos pelaajalla on 0 pistettä, hän häviää vaikka ruudukko ei olisi täynnä
        if score2 == 0 {
            winner = .player1
            return true
        } else if score1 == 0 {
            winner = .player2
            return true
        }
        
        // jos ruudukko ei ole täynnä, peli on kesken
        let totalPoints = score1 + score2
        if totalPoints < grid.size() {
            return false
        }
        
        // määritetään pelin lopputulos: voitto tai tasapeli
        if score1 > score2 {
            winner = .player1
        } else if score2 > score1 {
            winner = .player2
        } else {
            winner = .empty
        }
        
        return true
    }
    
    // MARK: - Helper and utility methods
    
    // kaikki sallitut siirrot kyseisellä hetkellä
    func legalMoves() -> [OthelloTile] {
        var legalTiles = [OthelloTile]()
        
        allTiles: for tile in grid.tiles {
            
            // ruudun täytyy olla vuorossa olevan pelaajan
            if tile.gameState != activePlayer {
                continue
            }
            
            // käydään läpi kaikissa suunnissa olevat ruudut
            directions: for direction in Directions.values {
                
                // jos suunnasta löytyi sallittu siirto, lisätään se listaan
                if let legalTile = nextLegalTile(fromTile: tile, forDirection: direction) {
                    legalTiles.append(legalTile)
                }
            }
        }
        
        return legalTiles
    }

    // apumetodi: palauttaa sallitun siirron tietyssä suunnassa, jos sellainen on
    private func nextLegalTile(fromTile tile: OthelloTile, forDirection direction: [Int]) -> OthelloTile? {
        
        let widthChange = direction[0]
        let heightChange = direction[1]
        var x = tile.x + widthChange
        var y = tile.y + heightChange
        
        
        guard let firstNeighbour = grid.getTile(forX: x, forY: y) else {
            // seuraavaa ruutua ei ole
            return nil
        }
        
        // ensimmäinen naapuri ei saa olla tyhjä tai oma
        if firstNeighbour.gameState == tile.gameState || firstNeighbour.gameState == .empty {
            return nil
        }
        
        neighbours: while true {
            // otetaan käsittelyyn seuraava ruutu
            x = x + widthChange
            y = y + heightChange
            
            guard let nextNeighbour = grid.getTile(forX: x, forY: y) else {
                // seuraavaa ruutua ei ole
                break
            }
            
            if nextNeighbour.gameState == tile.gameState {
                // ruutu oli oma
                break
            }
            
            if nextNeighbour.gameState == .empty {
                return nextNeighbour
            }
        }
        
        // suunnasta ei löytynyt valideja siirtoja
        return nil
    }
}


