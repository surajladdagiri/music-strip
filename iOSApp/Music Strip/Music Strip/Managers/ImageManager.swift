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
    private var known_colors:[(Int, Int, Int)] = [(0,0,0), (255,255,255), (255,0,0), (0,255,0), (0,0,255), (255, 128, 0), (255,255,0), (128,255,0), (0,255,128), (0,255,255), (0,128,255), (128,0,255), (255,0,255), (255, 0, 128)]
    private var mapped_colors:[String] = ["R0G0B0", "R255G255B255", "R255G0B0", "R0G255B0", "R0G0B255", "R255G50B0", "R255G200B0", "R128G255B0", "R0G255B20", "R0G255B128", "R0G128B255", "R128G0B255", "R255G0B128", "R255G0B25"]
    
    
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
    
    func mapEuclidianNoDuplicates(colors: [(Int, Int, Int)]) -> String{
        var used: Set<String> = []
        var return_string = ""
        for color in colors{
            let mapped = mapEuclidian(r: color.0, g: color.1, b: color.2)
            if !used.contains(mapped){
                used.insert(mapped)
                return_string += mapped + ":"
            }
        }
        return_string = String(return_string.dropLast())
        return return_string
    }
    
    func mapEuclidianAllowDuplicates(colors: [(Int, Int, Int)]) -> String{
        var return_string = ""
        for color in colors{
            let mapped = mapEuclidian(r: color.0, g: color.1, b: color.2)
            return_string += mapped + ":"
        }
        return_string = String(return_string.dropLast())
        return return_string
    }
    
    func getPaletteColorThief(image: UIImage, numberOfColors: Int, duplicates: Bool) -> String{
        guard let colors = ColorThief.getPalette(from: image, colorCount: numberOfColors, quality: 1, ignoreWhite: false) else {
            return "FAILED"
        }
        var returnString = ""
        var toBeMapped: [(Int, Int, Int)] = []
        for color in colors {
            toBeMapped.append((Int(color.r), Int(color.g), Int(color.b)))
        }
        if duplicates{
            returnString = mapEuclidianAllowDuplicates(colors: toBeMapped)
            print("ALLOWING DUPLICATES!!!!")
        }else{
            returnString = mapEuclidianNoDuplicates(colors: toBeMapped)
            print("NOT ALLOWING DUPLICATES!!!!")
        }
        return returnString
    }
}
