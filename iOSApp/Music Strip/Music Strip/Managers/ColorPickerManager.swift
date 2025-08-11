//
//  ColorPickerManager.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/10/25.
//


import SwiftUI


class ColorPickerDelegate: NSObject, UIColorPickerViewControllerDelegate {
    var didSelectColor: ((UIColor) -> Void)

    init(_ didSelectColor: @escaping ((UIColor) -> Void)) {
        self.didSelectColor = didSelectColor
    }
    
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        let selectedUIColor = viewController.selectedColor
        didSelectColor(selectedUIColor)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        print("dismiss colorPicker")
    }

}

struct ColorPickerView: UIViewControllerRepresentable {
    private let delegate: ColorPickerDelegate
    private let pickerTitle: String
    private let selectedColor: UIColor
    

    init(title: String, selectedColor: UIColor, didSelectColor: @escaping ((UIColor) -> Void)) {
        self.pickerTitle = title
        self.selectedColor = selectedColor
        self.delegate = ColorPickerDelegate(didSelectColor)
    }
 
    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let colorPickerController = UIColorPickerViewController()
        colorPickerController.delegate = delegate
        colorPickerController.title = pickerTitle
        colorPickerController.selectedColor = selectedColor
        colorPickerController.supportsAlpha = false
        return colorPickerController
    }

 
    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {}
}

extension UIColor {
    var r: Int {
        var red: CGFloat = 0
        getRed(&red, green: nil, blue: nil, alpha: nil)
        return Int(red * 255)
    }
    
    var g: Int {
        var green: CGFloat = 0
        getRed(nil, green: &green, blue: nil, alpha: nil)
        return Int(green * 255)
    }
    
    var b: Int {
        var blue: CGFloat = 0
        getRed(nil, green: nil, blue: &blue, alpha: nil)
        return Int(blue * 255)
    }
}
