import UIKit
import BasisTheoryElements

class ViewController: UIViewController {
    
    func authorizeSession(nonce: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let parameters = ["nonce": nonce]
        
        let url = URL(string: "http://localhost:4242/authorize")!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            completion(nil, error)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any]
                completion(json, nil)
            } catch let error {
                completion(nil, error)
            }
        })
        
        task.resume()
    }
    
    @IBAction func reveal(_ sender: Any) {
        let btPublicKey = Configuration.getConfiguration().btPublicKey!
        let btCardId = Configuration.getConfiguration().btCardId!
        let proxyKey = Configuration.getConfiguration().proxyKey!
        let issuerCardId = Configuration.getConfiguration().issuerCardId!
        
        BasisTheoryElements.createSession(apiKey: btPublicKey) { data, error in
            let sessionKey = data!.sessionKey!
            let nonce = data!.nonce!
            
            self.authorizeSession(nonce: nonce) { result, error in
                // retrieve card token from basis theory
                BasisTheoryElements.getTokenById(id: btCardId, apiKey: sessionKey) { data, error in
                    DispatchQueue.main.async {
                        self.cardNumberElement.setValue(elementValueReference: data!.data!.number!.elementValueReference)
                        
                        self.cardExpirationDateElement.setValue(
                            month: data!.data!.expiration_month!.elementValueReference,
                            year: data!.data!.expiration_year!.elementValueReference
                        )
                    }
                    
                    // retrieve card from issuer using proxy
                    let proxyHttpRequest = ProxyHttpRequest(method: .get, path: String("/" + issuerCardId))
                    BasisTheoryElements.proxy(
                        apiKey: sessionKey,
                        proxyKey: proxyKey,
                        proxyHttpRequest: proxyHttpRequest)
                    { response, data, error in
                        
                        DispatchQueue.main.async {
                            self.cardVerificationCodeElement.setValue(elementValueReference: data!.cvv!.elementValueReference)
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var cardNumberElement: CardNumberUITextField!
    @IBOutlet weak var cardExpirationDateElement: CardExpirationDateUITextField!
    @IBOutlet weak var cardVerificationCodeElement: CardVerificationCodeUITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cardNumberElement.layer.borderWidth = 1.0
        cardNumberElement.placeholder = "Card Number"
        cardNumberElement.backgroundColor = UIColor( red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0 )
        
        cardExpirationDateElement.layer.borderWidth = 1.0
        cardExpirationDateElement.placeholder = "Expiration Date"
        cardExpirationDateElement.backgroundColor = UIColor( red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0 )
        
        cardVerificationCodeElement.layer.borderWidth = 1.0
        cardVerificationCodeElement.placeholder = "CVC"
        cardVerificationCodeElement.backgroundColor = UIColor( red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0 )
    }
}

