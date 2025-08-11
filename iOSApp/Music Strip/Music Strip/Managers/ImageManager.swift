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
    private var known_colors:[(Int, Int, Int)] = [(0,0,0), (255,255,255), (255,0,0), (0,255,0), (0,0,255)]
    private var mapped_colors:[String] = ["R0G0B0", "R255G255B255", "R255G0B0", "R0G255B0", "R0G0B255"]
    
    
    func mapEuclidian(r: Int, g: Int, b: Int) -> String{
        var minIndex = -1
        var minDistance = Int.max
        for i in 0..<known_colors.count{
            let distance = Int(pow(Double(r-known_colors[i].0), 2.0)) + Int(pow(Double(g-known_colors[i].1), 2.0)) + Int(pow(Double(b-known_colors[i].2), 2.0))
            if distance < minDistance{
                minDistance = distance
                minIndex = i
            }
        }
        return mapped_colors[minIndex]
    }
    
    func getPaletteColorThief(image: UIImage, numberOfColors: Int) -> String{
        guard let colors = ColorThief.getPalette(from: image, colorCount: numberOfColors, quality: 1, ignoreWhite: true) else {
            return "FAILED"
        }
        var returnString = ""
        for color in colors {
            let mapped_color = mapEuclidian(r: Int(color.r), g: Int(color.g), b: Int(color.b))
            returnString += "R\(color.r)G\(color.g)B\(color.b):"
        }
        returnString = String(returnString.dropLast())
        return returnString
    }
}
