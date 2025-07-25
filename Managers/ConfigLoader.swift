import Foundation

class ConfigLoader {
    private var properties = [String: String]()
    init(filename: String = "swv.properties") {
        guard let filePath = Bundle.main.path(forResource: filename, ofType: nil),
              let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            print("WARNING: \(filename) not found. Using default values."); return
        }
        let lines = content.split { $0.isNewline }
        for line in lines {
            if line.starts(with: "#") || line.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            let parts = line.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                properties[String(parts[0]).trimmingCharacters(in: .whitespaces)] = String(parts[1]).trimmingCharacters(in: .whitespaces)
            }
        }
    }
    func getString(key: String, defaultValue: String) -> String { return properties[key, default: defaultValue] }
    func getBool(key: String, defaultValue: Bool) -> Bool { return (properties[key] as NSString?)?.boolValue ?? defaultValue }
    func getStringArray(key: String, defaultValue: [String]) -> [String] {
        guard let value = properties[key], !value.isEmpty else { return defaultValue }
        return value.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
    }
}
