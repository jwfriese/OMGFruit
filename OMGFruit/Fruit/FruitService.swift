import Foundation

class FruitService {
    var httpClient: HTTPClient?
    var fruitDeserializer: FruitDeserializer?

    func getFruit(_ completion: ((Fruit?, OMGError?) -> ())?) {
        guard let httpClient = httpClient else { return }

        let urlString = "http://localhost:8080/fruit"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        httpClient.doRequest(request as URLRequest) { data, response, error in
            guard let completion = completion else { return }
            guard let data = data else {
                completion(nil, error)
                return
            }

            let result = self.fruitDeserializer?.deserialize(data)
            completion(result?.fruit, result?.error)
        }
    }
}
