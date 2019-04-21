//
//  MenuViewController.swift
//  Othello
//
//  Created by Joonas Junttila on 21/04/2019.
//  Copyright © 2019 Joonas Junttila. All rights reserved.
//

import Foundation
import UIKit

class MenuVC: UIViewController {
    
    //MARK: - Properties
    var gridWidth = 6
    var gridHeight = 8
    var player1Name = "Pelaaja1"
    var player2Name = "Pelaaja2"
    
    //MARK: - Outlets
    @IBOutlet weak var ruudukkoLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    //MARK: - Actions
    @IBAction func sliderWasMoved(_ sender: UISlider) {
        // haetaan sliderin arvot
        gridWidth = Int(sender.value * 2)
        gridHeight = Int(sender.value * 3)
        
        // pakotetaan kahdella jaollisiksi
        var remainder = gridWidth % 2
        gridWidth = gridWidth - remainder
        remainder = gridHeight % 2
        gridHeight = gridHeight - remainder
        
        updateUI()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGame" {
            let destinationVC = segue.destination as! OthelloViewController
            destinationVC.player1Name = self.player1Name
            destinationVC.player2Name = self.player2Name
            destinationVC.gridWidth = self.gridWidth
            destinationVC.gridHeight = self.gridHeight
        }
    }
    
    private func updateUI(){
        ruudukkoLabel.text = "Ruudukko: \(gridWidth) x \(gridHeight)"
    }
}
