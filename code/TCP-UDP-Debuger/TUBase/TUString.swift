//
//  TUString.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/29.
//  Copyright © 2015年 Neva. All rights reserved.
//

import Foundation

extension Character {
    func intValue() -> Int {
        for s in String(self).utf8 {
            return Int(s)
        }
        return 0 as Int
    }
    func utf8Value() -> UInt8 {
        for s in String(self).utf8 {
            return s
        }
        return 0
    }
    
    func utf16Value() -> UInt16 {
        for s in String(self).utf16 {
            return s
        }
        return 0
    }
    
    func unicodeValue() -> UInt32 {
        for s in String(self).unicodeScalars {
            return s.value
        }
        return 0
    }
}


extension String {
    
    private static func asciiIsHex(val:Int) -> Bool {
        
        let zeroInt = Character("0").intValue()
        let nineInt = Character("9").intValue()
        let aInt = Character("a").intValue()
        let fInt = Character("f").intValue()
        let AInt = Character("A").intValue()
        let FInt = Character("F").intValue()
        
        if(val >= zeroInt && val <= nineInt) {
            return true
        }
        
        if(val >= aInt && val <= fInt) {
            return true
        }
        
        if(val >= AInt && val <= FInt) {
            return true
        }
        
        return false
    }

    private static func asciiToHex(ascii:String) -> String {
        
        let length = ascii.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)
        let characters = Array(ascii.characters)
        var hexArray:[Int] = []
        var i = 0
        
        let slashInt = Character("\\").intValue()
        let rInt = Character("r").intValue()
        let nInt = Character("n").intValue()
        
        for (i = 0; i < length; i++) {
            let char1 = characters[i].intValue()
            //        hexArray.append(char1)
            //        continue
            if char1 == slashInt  && i + 1 < length{
                let char2 = characters[i+1].intValue()
                
                if(char2 == slashInt) {
                    hexArray.append(0x5C)
                    i++
                    continue
                }
                if(char2 == rInt) {
                    hexArray.append(0x0d)
                    i++
                    continue
                }
                if(char2 == nInt) {
                    hexArray.append(0x0a)
                    i++
                    continue
                }
                
                if(asciiIsHex(char2)) {
                    i++
                    var testString = ""
                    let charC2 = Character(UnicodeScalar(char2))
                    testString.append(charC2)
                    var result : UInt32 = 0
                    if(i + 1 < length) {
                        let char3 = characters[i+1].intValue()
                        if(asciiIsHex(char3)) {
                            i++
                            
                            let charC3 = Character(UnicodeScalar(char3))
                            testString.append(charC3)
                            let scanner = NSScanner(string: testString)
                            if scanner.scanHexInt(&result) {
                                hexArray.append(Int(result))
                            }
                        } else {
                            let scanner = NSScanner(string: testString)
                            if scanner.scanHexInt(&result) {
                                hexArray.append(Int(result))
                            }
                        }
                    } else {
                        let scanner = NSScanner(string: testString)
                        if scanner.scanHexInt(&result) {
                            hexArray.append(Int(result))
                        }
                    }
                    continue
                }
                
            } else {
                hexArray.append(char1)
            }
        }
        
        var returnString:String = ""
        for hex in hexArray {
            let st = NSString(format:"%02X", hex) as String
            returnString += " " + st
            
            
        }
        //hexArray.join(" ")
        returnString = returnString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        return returnString.lowercaseString
    }
    
    public func hexString() -> String {
        return String.asciiToHex(self)
    }
}