//
//  MenuViewController.swift
//  Othello
//
//  Created by Joonas Junttila on 21/04/2019.
//  Copyright © 2019 Joonas Junttila. All rights reserved.
//

import Foundation
import UIKit

class MenuVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: - Properties
    var gridWidth = 6
    var gridHeight = 8
    var player1 = Player.init(name: "Player1", color: .black)
    var player2 = Player.init(name: "Player2", color: .blue)
    
    //MARK: - Outlets
    @IBOutlet weak var ruudukkoLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var colorPickerView: UIPickerView!
    @IBOutlet weak var aiSwitch: UISwitch!
    
    //MARK: - Actions
    @IBAction func sliderWasMoved(_ sender: UISlider) {
        
        // haetaan sliderin arvot
        let width = Int(sender.value * 2)
        let height = Int(sender.value * 2)
        
        // pakotetaan kahdella jaollisiksi
        gridWidth = width - width % 2
        gridHeight = height - height % 2
        
        updateUI()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGameButton.layer.cornerRadius = startGameButton.frame.height/2
        aiSwitch.setOn(false, animated: false)
        colorPickerView.selectRow(1, inComponent: 1, animated: false)
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "startGame" else {
            print("Invalid segue: \(segue)")
            return
        }
        
        let destinationVC = segue.destination as! OthelloViewController
        destinationVC.player1 = self.player1
        destinationVC.player2 = self.player2
        destinationVC.gridWidth = self.gridWidth
        destinationVC.gridHeight = self.gridHeight
        destinationVC.player2UsesAI = aiSwitch.isOn
    }
    
    private func updateUI(){
        ruudukkoLabel.text = "Ruudukko: \(gridWidth) x \(gridHeight)"
    }
    
    // MARK: - Delegate Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let values = Color.allCases
        return values[row].value()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Color.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
        let rowCount = Color.allCases.count
        var otherComponent: Int
        var selectedColor = Color.allCases[row]
        
        // päätellään toisen pelaajan valinta
        if component == 0 { otherComponent = 1 }
        else { otherComponent = 0 }
        let otherRow = colorPickerView.selectedRow(inComponent: otherComponent)
        
        // jos valinnat ovat samat, vaihdetaan valintaa yhdellä
        if row == otherRow {
            
            var newRow = row + 1
            if newRow == rowCount { newRow = row - 1 }
        
            colorPickerView.selectRow(newRow, inComponent: component, animated: true)
            selectedColor = Color.allCases[newRow]
        }
        
        // asetetaan valittu väri pelaajalle
        switch component {
        case 0: player1.color = selectedColor
        case 1: player2.color = selectedColor
        default: break
        }
        
        
    }
    
}
