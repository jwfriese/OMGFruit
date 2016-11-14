import UIKit

class FruitDeserializer {
    func deserialize(_ data: Data) -> (fruit: Fruit?, error: DeserializationError?) {
        var fruitJSONObject: Any?
        do {
            fruitJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        guard let fruitJSON = fruitJSONObject as? NSDictionary else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidInputFormat))
        }

        guard let name = fruitJSON["name"] as? String else {
            return (nil, nil)
        }
        guard let description = fruitJSON["description"] as? String else {
            return (nil, nil)
        }
        guard let imageBase64String = fruitJSON["image"] as? String else {
            return (nil, nil)
        }

        let imageDataOpt = Data(base64Encoded: imageBase64String, options: Data.Base64DecodingOptions())

        guard let imageData = imageDataOpt else {
            return (nil, nil)
        }

        guard let image = UIImage(data: imageData) else {
            return (nil, nil)
        }

        let fruit = Fruit(name: name, description: description, image: image)
        return (fruit, nil)

    }
}
