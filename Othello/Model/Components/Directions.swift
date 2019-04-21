//
//  Directions.swift
//  Othello
//
//  Created by Joonas Junttila on 21/04/2019.
//  Copyright © 2019 Joonas Junttila. All rights reserved.
//

import Foundation

// kaikki ilmansuunnat muodossa [x,y]
struct Directions {
    static let UP           = [0,1]
    static let UP_RIGHT     = [1,1]
    static let RIGHT        = [1,0]
    static let DOWN_RIGHT   = [1,-1]
    static let DOWN         = [0,-1]
    static let DOWN_LEFT    = [-1,-1]
    static let LEFT         = [-1,0]
    static let UP_LEFT      = [-1,1]
    
    // looppausta varten
    static let values = [Directions.UP, Directions.UP_RIGHT, Directions.RIGHT, Directions.DOWN_RIGHT, Directions.DOWN, Directions.DOWN_LEFT, Directions.LEFT, Directions.UP_LEFT]
}
