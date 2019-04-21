//
//  ViewController.swift
//  Othello
//
//  Created by Joonas Junttila on 20/04/2019.
//  Copyright © 2019 Joonas Junttila. All rights reserved.
//

import UIKit

struct Colors {
    static let PLAYER1 = UIColor.red
    static let PLAYER2 = UIColor.blue
    static let ILLEGAL_TILE = UIColor.lightGray
    static let LEGAL_TILE = UIColor.green
    static let DARK_TEXT = UIColor.darkText
}

class OthelloViewController: UIViewController {
    
    // MARK - Properties
    private var game: Game! = nil
    var gridWidth = 6
    var gridHeight = 8
    private var buttons = [UIButton]()
    var player1Name = "Pelaaja1"
    var player2Name = "Pelaaja2"
    let activityIndicator = UIActivityIndicatorView()

    // MARK - Outlets
    @IBOutlet weak var gridStackView: UIStackView!
    @IBOutlet weak var scoreLabel1: UILabel!
    @IBOutlet weak var scoreLabel2: UILabel!
    
    // MARK - Actions
    @objc func buttonPressed(_ sender: UIButton) {
        game.makeAMove(forId: sender.tag)
        updateUI()
    }
    
    @IBAction func newGameButtonPressed(_ sender: UIButton) {
        game.startOver()
        updateUI()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = Game.init(x: gridWidth, y: gridHeight, firstPlayer: .player1)
        setUpGrid()
        scoreLabel1.textColor = Colors.PLAYER1
        scoreLabel2.textColor = Colors.PLAYER2
    }
    
    func setUpGrid(){
        
        for y in 1 ... game.grid.height {
            
            var rowButtons = [UIButton]()
            
            for x in 1 ... game.grid.width {
                
                let buttonNumber = x + (y - 1) * game.grid.width
                let button = UIButton()
                button.tag = buttonNumber
                button.translatesAutoresizingMaskIntoConstraints = false
                button.addTarget(self, action: #selector(self.buttonPressed(_:)), for: .touchUpInside)
                
                // ruuduille voidaan asettaa numerot näkyviin tästä
//                button.setTitle("\(buttonNumber)", for: .normal)
                
                
                // pyöristetään reunat
                button.layer.cornerRadius = CGFloat(210/gridHeight)
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.black.cgColor
                
                // lisätään painike listaan ja riville
                buttons.append(button)
                rowButtons.append(button)
            }
            
            let row = UIStackView(arrangedSubviews: rowButtons)
            row.axis = .horizontal
            row.spacing = CGFloat(50/gridHeight)
            row.distribution = .fillEqually
            row.translatesAutoresizingMaskIntoConstraints = false
            
            gridStackView.spacing = row.spacing
            gridStackView.addArrangedSubview(row)
        }
        
        updateUI()
    }
    
    func getButton(forX x: Int, forY y: Int) -> UIButton? {
        
        guard let tile = game.grid.getTile(forX: x, forY: y) else {
            return nil
        }
        
        if tile.id > buttons.count {
            return nil
        }
        
        return buttons[tile.id - 1]
    }

    func updateUI(){
        
        // päivitetään ruudut vastaamaan pelitilannetta
        for button in buttons {
            if let tile = game.grid.getTile(forId: button.tag) {
                switch tile.gameState {
                case .empty:
                    button.backgroundColor = Colors.ILLEGAL_TILE
                case .player1:
                    button.backgroundColor = Colors.PLAYER1
                case .player2:
                    button.backgroundColor = Colors.PLAYER2
                }
    
                for legalTile in game.legalMoves() {
                    if button.tag == legalTile.id {
                        button.backgroundColor = Colors.LEGAL_TILE
                    }
                }
                
                button.setTitleColor(Colors.DARK_TEXT, for: .normal)
            }
        }
        
        // päivitetään pistemäärät
        scoreLabel1.text = "\(player1Name): \(game.score1)p"
        scoreLabel2.text = "\(player2Name): \(game.score2)p"
        
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
}

