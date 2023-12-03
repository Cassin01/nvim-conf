import Foundation
var inDarkMode: Bool {
    let mode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
    return mode == "Dark"
}
print(inDarkMode)
