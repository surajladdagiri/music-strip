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
    
    
    
    func extractPixelData(image: UIImage, ignoreWhite: Bool) -> [(Int, Int, Int)]?{
        guard let cgImage = image.cgImage,
            let dataProvider = cgImage.dataProvider,
            let pixelData = dataProvider.data else {
                print("FAILED TO GET PIXEL DATA")
                return nil
            }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let width = cgImage.width
        let height = cgImage.height
        var pixelArray: [(Int, Int, Int)] = []
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let r = Int(data[offset])
                let g = Int(data[offset + 1])
                let b = Int(data[offset + 2])
                
                
                if !ignoreWhite || r < 175 || g < 175 || b < 175{
                    pixelArray.append((r, g, b))
                }
            }
        }
        return pixelArray
    }
    
    func distance_squared(point1: (Int, Int, Int), point2:(Int, Int, Int)) -> Int{
        let distance = Int(pow(Double(point1.0 - point2.0), 2.0)) + Int(pow(Double(point1.1 - point2.1), 2.0)) + Int(pow(Double(point1.2 - point2.2), 2.0))
        return distance
    }
    
    
    func kmeans_clustering(pixelArray: [(Int, Int, Int)], numClusters: Int, allowDuplicates: Bool) -> String{
        var centroids: [(Int, Int, Int)] = []
        var clusters: [[(Int, Int, Int)]] = Array(repeating: [], count: numClusters)

        for i in 0..<numClusters{
            //centroids.append((Int.random(in: 0...255),Int.random(in: 0...255),Int.random(in: 0...255)))
            centroids.append(pixelArray[Int.random(in: 0...(pixelArray.count-1))])
            clusters[i].append(centroids[i])
        }
        
        for pixel in pixelArray{
            var minIndex = -1
            var minDistance = Int.max
            for i in 0..<numClusters{
                let distance = distance_squared(point1: pixel, point2: centroids[i])
                if distance < minDistance{
                    minDistance = distance
                    minIndex = i
                }
            }
            clusters[minIndex].append(pixel)
        }
        
        
        var iterations = 0
        let maxIterations = 100
        var changed = true
        while iterations < maxIterations && changed{
            changed = false
            for i in 0..<numClusters{
                let count = clusters[i].count
                if count == 0{
                    continue
                }
                var ravg = 0
                var gavg = 0
                var bavg = 0
                for p in clusters[i]{
                    ravg += p.0
                    gavg += p.1
                    bavg += p.2
                }
                ravg = ravg/count
                gavg = gavg/count
                bavg = bavg/count
                if centroids[i] != (ravg, gavg, bavg){
                    changed = true
                    centroids[i] = (ravg, gavg, bavg)
                }
            }
            
            
            if changed{
                clusters = Array(repeating: [], count: numClusters)
                for pixel in pixelArray{
                    var minIndex = -1
                    var minDistance = Int.max
                    for i in 0..<numClusters{
                        let distance = distance_squared(point1: pixel, point2: centroids[i])
                        if distance < minDistance{
                            minDistance = distance
                            minIndex = i
                        }
                    }
                    clusters[minIndex].append(pixel)
                }
            }
            iterations += 1
            print("Iteration \(iterations)")
        }
        var toBeRemoved:[Int] = []
        for (idx, cluster) in clusters.enumerated(){
            if cluster.isEmpty{
                toBeRemoved.append(idx)
            }
        }
        
        for idx in toBeRemoved.reversed(){
            centroids.remove(at: idx)
        }
        
        var return_colors = ""
        if allowDuplicates{
            return_colors = mapEuclidianAllowDuplicates(colors: centroids)
        }else{
            return_colors = mapEuclidianNoDuplicates(colors: centroids)
        }
        
        return return_colors
    }
    
    
    
    
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
        guard let img = image.downscale(to: CGSize(width: 100, height: 100)) else{
            return "FAILED"
        }
        guard let colors = ColorThief.getPalette(from: img, colorCount: numberOfColors, quality: 1, ignoreWhite: true) else {
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
    
    func getPaletteKMeans(image: UIImage, numberOfColors: Int, duplicates: Bool, ignorewhite: Bool = true) -> String{
        guard let img = image.downscale(to: CGSize(width: 100, height: 100)) else{
            return "FAILED"
        }
        guard let pixels = extractPixelData(image: img, ignoreWhite: ignorewhite) else {
            return "FAILED"
        }
        let return_string = kmeans_clustering(pixelArray: pixels, numClusters: numberOfColors, allowDuplicates: duplicates)
        return return_string
    }
    
    
}
extension UIImage {
    func downscale(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return scaledImage
    }
}
