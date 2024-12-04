//
//  UIHelper.swift
//  KinopoiskLoginAndSearch
//
//  Created by Roman Vakulenko on 14.09.2024.
//


import UIKit
import RswiftResources

enum UIHelper {
    
    enum Attributed {
        static let grayMedium14: [NSAttributedString.Key: Any] = [.font: Font.InterMedium14, .foregroundColor: UIColor.gray]

        static let whiteInterBold18: [NSAttributedString.Key: Any] = [.font: Font.InterBold18, .foregroundColor: UIColor.white]

        static let whiteInterBold22: [NSAttributedString.Key: Any] = [.font: Font.InterBold22, .foregroundColor: UIColor.white]

        static let cyanSomeBold18: [NSAttributedString.Key: Any] = [.font: Font.InterBold18, .foregroundColor: Color.cyanSome]

        static let cyanSomeBold22: [NSAttributedString.Key: Any] = [.font: Font.InterBold22, .foregroundColor: Color.cyanSome]
    }
    
    enum Font {
        static let InterMedium14 = UIFont(name: "Inter-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        static let InterBold18 = UIFont(name: "Inter-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        static let InterBold22 = UIFont(name: "Inter-Bold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .bold)
    }
    
    enum Color {
        static let almostBlack = UIColor(red: 0.08, green: 0.05, blue: 0.04, alpha: 1.00)
        static let gray = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.00)
        static let cyanSome = UIColor(red: 0.27, green: 0.87, blue: 0.82, alpha: 1.00)
    }

    enum Margins {
        static let small1px: CGFloat = 1
        static let small2px: CGFloat = 2
        static let small4px: CGFloat = 4
        static let small6px: CGFloat = 6
        
        static let medium8px: CGFloat = 8
        static let medium10px: CGFloat = 10
        static let medium12px: CGFloat = 12
        static let medium14px: CGFloat = 14
        static let medium16px: CGFloat = 16
        static let medium18px: CGFloat = 18
        
        static let large20px: CGFloat = 20
        static let large22px: CGFloat = 22
        static let large23px: CGFloat = 23
        static let large24px: CGFloat = 24
        static let large26px: CGFloat = 26
        static let large30px: CGFloat = 30
        static let large32px: CGFloat = 32
        
        static let huge36px: CGFloat = 36
        static let huge40px: CGFloat = 40
        static let huge42px: CGFloat = 42
        static let huge48px: CGFloat = 48
        static let huge56px: CGFloat = 56
    }

    enum Images {
        //system images
//        magnifyingglass
//        chevron.down
//        chevron.backward
//        link

        static let logOffCyan24px = UIImage(named: "logOff24px") ?? UIImage()
        static let sortCyan24px = UIImage(named: "sortCyan") ?? UIImage()
        static let imagePlaceholder100px = UIImage(named: "imagePlaceholder100px") ?? UIImage()

    }
}



