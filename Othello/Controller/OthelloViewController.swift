//
//  ViewController.swift
//  Othello
//
//  Created by Joonas Junttila on 20/04/2019.
//  Copyright © 2019 Joonas Junttila. All rights reserved.
//

import UIKit

class OthelloViewController: UIViewController {
    
    // MARK - Properties
    private var game: Game! = nil
    var gridWidth = 6
    var gridHeight = 8
    private var buttons = [UIButton]()
    var player1 = Player()
    var player2 = Player()
    let activityIndicator = UIActivityIndicatorView()
    var player2UsesAI = false

    // MARK - Outlets
    @IBOutlet weak var gridStackView: UIStackView!
    @IBOutlet weak var scoreLabel1: UILabel!
    @IBOutlet weak var scoreLabel2: UILabel!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var newGameButton: UIButton!
    
    // MARK - Actions
    @objc func buttonPressed(_ sender: UIButton) {
        
        // Pelataan ihmisen vuoro
        game.makeAMove(forId: sender.tag)
        updateUI()
        
        // Pelataan mahdolliset tietokoneen vuorot
        while game.activePlayer == .player2 && player2UsesAI {
            game.playComputerTurn()
            updateUI()
        }
    }
    
    @IBAction func newGameButtonPressed(_ sender: UIButton) {
        game.startOver()
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newGameButton.layer.cornerRadius = newGameButton.frame.height/2
        game = Game.init(x: gridWidth, y: gridHeight, firstPlayer: .player1)
        if player2UsesAI { player2.name = "Computer" }
        setUpGrid()
    }
    
    func setUpGrid(){
        
        var buttonID = 1
        
        for _ in 1 ... game.grid.height {
            
            var rowButtons = [UIButton]()
            
            for _ in 1 ... game.grid.width {

                // Luodaan painike
                let button = UIButton()
                button.tag = buttonID
                button.imageView?.contentMode = .scaleAspectFit
                button.translatesAutoresizingMaskIntoConstraints = false
                button.addTarget(self, action: #selector(self.buttonPressed(_:)), for: .touchUpInside)
                
                // lisätään painike listaan ja riville
                buttons.append(button)
                rowButtons.append(button)
                
                buttonID += 1
            }
            
            let row = UIStackView(arrangedSubviews: rowButtons)
            row.axis = .horizontal
            row.spacing = 1
            row.distribution = .fillEqually
            row.translatesAutoresizingMaskIntoConstraints = false
            gridStackView.addArrangedSubview(row)
        }
        
        updateUI()
    }
    
    func getButton(forId id: Int) -> UIButton? {
        return buttons.first(where: { $0.tag == id })
    }
    
    func getButton(forX x: Int, forY y: Int) -> UIButton? {
        guard let tile = game.grid.getTile(forX: x, forY: y) else { return nil }
        return getButton(forId: tile.id)
    }

    func updateUI(){
        
        // päivitetään ruudut vastaamaan pelitilannetta
        updateAllButtons()
        
        // päivitetään pistemäärät
        scoreLabel1.text = "\(player1.name): \(game.score1)p"
        scoreLabel2.text = "\(player2.name): \(game.score2)p"
        
        // päivitetään aktiivisen pelaajan label boldiksi
        switch game.activePlayer {
        case .player1:
            scoreLabel1.font = UIFont.boldSystemFont(ofSize: 16.0)
            scoreLabel2.font = UIFont.systemFont(ofSize: 16.0)
        case .player2:
            scoreLabel2.font = UIFont.boldSystemFont(ofSize: 16.0)
            scoreLabel1.font = UIFont.systemFont(ofSize: 16.0)
        default: break
        }
    
    }
    
    private func updateAllButtons(){
        
        let legalTags = game.legalMoves().map { (legalTile) -> Int in
            return legalTile.id
        }
        
        for button in buttons {
            
            if legalTags.contains(button.tag) {
                button.setImage(UIImage.init(named: TileImages.legal), for: .normal)
//                button.backgroundColor = .yellow
                continue
            }
            
            guard let tile = game.grid.getTile(forId: button.tag) else { continue }
            
            var image: UIImage
            var color: UIColor
            switch tile.gameState {
            case .empty:
                image = UIImage.init(named: TileImages.empty)!
                color = .green
            case .player1:
                image = player1.getImage()
                color = .red
            case .player2:
                image = player2.getImage()
                color = .blue
            }
            
            button.setImage(image, for: .normal)
            button.setTitleColor(color, for: .disabled)
//            button.backgroundColor = color
        }
    }
    
//    private func updateOnlyChangedButtons(){
//
//        // päivitetään muuttuneet ruudut
//        for tile in game.changedTiles {
//            guard let button = getButton(forId: tile.id) else {
//                continue
//            }
//
//            switch tile.gameState {
//
//            case .player1: button.backgroundColor = Colors.PLAYER1
//            case .player2: button.backgroundColor = Colors.PLAYER2
//            case .empty: button.backgroundColor = Colors.ILLEGAL_TILE
//
//            }
//        }
//
//        // päivitetään näkyviin sallitut siirrot
//        for legalTile in game.legalMoves() {
//            guard let button = getButton(forId: legalTile.id) else {
//                continue
//            }
//            button.backgroundColor = Colors.LEGAL_TILE
//        }
//
//        // päivitetään edelliset sallitut siirrot takaisin
//        for tile in game.previousLegalTiles {
//            guard let button = getButton(forId: tile.id) else {
//                continue
//            }
//
//            switch tile.gameState {
//            case .empty:
//                button.backgroundColor = Colors.ILLEGAL_TILE
//            case .player1:
//                button.backgroundColor = Colors.PLAYER1
//            case .player2:
//                button.backgroundColor = Colors.PLAYER2
//            }
//        }
//    }
}

