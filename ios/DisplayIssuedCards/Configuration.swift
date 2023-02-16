import Foundation

struct EnvConfig: Decodable {
    let btCardId: String?
    let issuerCardId: String?
    let proxyKey: String?
    let btPublicKey: String?
    
    init() {
        self.btCardId = nil
        self.issuerCardId = nil
        self.proxyKey = nil
        self.btPublicKey = nil
    }
}

extension String: Error {}

class Configuration {
    static public func getConfiguration() -> EnvConfig {
        do {
            let url = Bundle(for: Configuration.self).path(forResource: "Env", ofType: "plist")!
            let data = FileManager.default.contents(atPath: url)!
            
            return try PropertyListDecoder().decode(EnvConfig.self, from: data)
        } catch {
            print(error)
        }
        
        return EnvConfig()
    }
}
