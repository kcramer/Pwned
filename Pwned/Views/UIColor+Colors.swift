//
//  UIColor+Custom.swift
//  Pwned
//
//  Created by Kevin on 10/29/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import UIKit

public extension UIColor {
    convenience init(hue: Int, saturation: Int, brightness: Int) {
        self.init(hue: CGFloat(hue) / 360.0,
                  saturation: CGFloat(saturation) / 100.0,
                  brightness: CGFloat(brightness) / 100.0,
                  alpha: 1.0)
    }

    public static let flatBlue = UIColor(hue: 224, saturation: 50, brightness: 63)
    public static let flatBlueDark = UIColor(hue: 224, saturation: 56, brightness: 61)
    public static let flatPurple = UIColor(hue: 253, saturation: 52, brightness: 77)
    public static let flatPurpleDark = UIColor(hue: 253, saturation: 56, brightness: 64)
    public static let flatPlum = UIColor(hue: 300, saturation: 45, brightness: 37)
    public static let flatPlumDark = UIColor(hue: 300, saturation: 46, brightness: 31)
    public static let flatCoffee = UIColor(hue: 25, saturation: 31, brightness: 64)
    public static let flatCoffeeDark = UIColor(hue: 25, saturation: 34, brightness: 56)
    public static let flatSkyBlue = UIColor(hue: 204, saturation: 76, brightness: 86)
    public static let flatSkyBlueDark = UIColor(hue: 204, saturation: 78, brightness: 73)
    public static let flatGray = UIColor(hue: 184, saturation: 10, brightness: 65)
    public static let flatGrayDark = UIColor(hue: 184, saturation: 10, brightness: 55)
    public static let lightGray = UIColor(hue: 0, saturation: 0, brightness: 75)
    public static let darkGray = UIColor(hue: 0, saturation: 0, brightness: 40)
    public static let flatPowderBlue = UIColor(hue: 222, saturation: 24, brightness: 95)
    public static let flatPowderBlueDark = UIColor(hue: 222, saturation: 28, brightness: 84)
    public static let flatNavyBlue = UIColor(hue: 210, saturation: 45, brightness: 37)
    public static let flatNavyBlueDark = UIColor(hue: 210, saturation: 45, brightness: 31)
    public static let flatGreen = UIColor(hue: 145, saturation: 77, brightness: 80)
    public static let flatForestGreen = UIColor(hue: 138, saturation: 45, brightness: 37)
    public static let flatOrange = UIColor(hue: 28, saturation: 85, brightness: 90)
    public static let flatOrangeDark = UIColor(hue: 24, saturation: 100, brightness: 83)
    public static let flatRed = UIColor(hue: 6, saturation: 74, brightness: 91)
    public static let flatYellow = UIColor(hue: 48, saturation: 99, brightness: 100)
    public static let flatGreenDark = UIColor(hue: 145, saturation: 78, brightness: 68)
    public static let flatSand = UIColor(hue: 42, saturation: 25, brightness: 94)
    public static let flatSandDark = UIColor(hue: 42, saturation: 30, brightness: 84)
    public static let flatLime = UIColor(hue: 74, saturation: 70, brightness: 78)
    public static let flatLimeDark = UIColor(hue: 74, saturation: 81, brightness: 69)
}
