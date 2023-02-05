import Cocoa
import InputMethodKit
import Foundation

class InputSource {
    fileprivate static var inputSources: [TISInputSource] {
        let inputSourceNSArray = TISCreateInputSourceList(nil, false).takeRetainedValue() as NSArray
        return inputSourceNSArray as! [TISInputSource]
    }

    fileprivate static var selectCapableInputSources: [TISInputSource] {
        return inputSources.filter({ $0.isSelectCapable })
    }

    static func change(id: String) {
        guard let inputSource = selectCapableInputSources.filter({ $0.id == id }).first else { return }
        TISSelectInputSource(inputSource)
    }

    // 確認用
    static func print() {
        for source in inputSources {
            Swift.print("id:[\(source.id)]")
            Swift.print("localizedName:[\(source.localizedName)]")
            Swift.print("isSelectCapable:[\(source.isSelectCapable)]")
            Swift.print("isSelected:[\(source.isSelected)]")
            Swift.print("sourceLanguages:[\(source.sourceLanguages)]")
            Swift.print("--------------------")
        }
    }
}

extension TISInputSource {
    func getProperty(_ key: CFString) -> AnyObject? {
        guard let cfType = TISGetInputSourceProperty(self, key) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(cfType).takeUnretainedValue()
    }

    var id: String {
        return getProperty(kTISPropertyInputSourceID) as! String
    }

    var localizedName: String {
        return getProperty(kTISPropertyLocalizedName) as! String
    }

    var isSelectCapable: Bool {
        return getProperty(kTISPropertyInputSourceIsSelectCapable) as! Bool
    }

    var isSelected: Bool {
        return getProperty(kTISPropertyInputSourceIsSelected) as! Bool
    }

    var sourceLanguages: [String] {
        return getProperty(kTISPropertyInputSourceLanguages) as! [String]
    }
}

//  ╭──────────────────────────────────────────────────────────────────────────────╮
//  │                                  Main Loop                                   │
//  ╰──────────────────────────────────────────────────────────────────────────────╯

let arg = CommandLine.arguments
if arg.count == 2 {
    InputSource.change(id: arg[1])
} else {
    InputSource.print()
}

//  ╭──────────────────────────────────────────────────────────────────────────────╮
//  │                                  Change IME                                  │
//  ╰──────────────────────────────────────────────────────────────────────────────╯
// Ref: https://qiita.com/SolaRayLino/items/8d01eebb550d871c35cd
// Run: `swift ime.swift`
// Compile: `swiftc -emit-executable ime.swift`
// Execute: `./ime`

