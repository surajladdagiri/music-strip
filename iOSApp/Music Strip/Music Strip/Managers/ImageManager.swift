//
//  ImageManager.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/9/25.
//

import Foundation
import SwiftUI
import ColorThiefSwift

class ImageManager: NSObject, ObservableObject {
    
    func getPaletteColorThief(image: UIImage, numberOfColors: Int) -> String{
        guard let colors = ColorThief.getPalette(from: image, colorCount: 10, quality: 1, ignoreWhite: true) else {
            return "FAILED"
        }
        var returnString = ""
        for color in colors {
            returnString += "R\(color.r)G\(color.g)B\(color.b):"
        }
        returnString = String(returnString.dropLast())
        
        return returnString
    }
}
