//
//  Player.swift
//  Othello
//
//  Created by Joonas Junttila on 21/04/2019.
//  Copyright © 2019 Joonas Junttila. All rights reserved.
//

import Foundation
import UIKit

class Player {
    var name: String
    var color: Color
    
    init() {
        self.name = "Player"
        self.color = .white
    }
    
    init(name: String, color: Color) {
        self.name = name
        self.color = color
    }
    
    func getImage() -> UIImage {
        
        var imageName: String
        
        switch color {
        case .black:    imageName = TileImages.black
        case .blue:     imageName = TileImages.blue
        case .green:    imageName = TileImages.green
        case .orange:   imageName = TileImages.orange
        case .red:      imageName = TileImages.red
        case .white:    imageName = TileImages.white
        case .yellow:   imageName = TileImages.yellow
        }
        
        return UIImage.init(named: imageName)!
    }
    
    
}

enum Color: String, CaseIterable {
    case black = "Musta"
    case blue = "Sininen"
    case green = "Vihreä"
    case orange = "Oranssi"
    case red = "Punainen"
    case white = "Valkoinen"
    case yellow = "Keltainen"
    
    func value() -> String {
        return self.rawValue
    }
}



