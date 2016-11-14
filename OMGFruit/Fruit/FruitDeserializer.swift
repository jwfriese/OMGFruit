import UIKit

class FruitDeserializer {
    func deserialize(_ data: Data) -> (fruit: Fruit?, error: DeserializationError?) {
        var fruitJSONObject: Any?
        do {
            fruitJSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { }

        guard let fruitJSON = fruitJSONObject as? NSDictionary else {
            return (nil, DeserializationError(details: "Could not interpret data as JSON dictionary", type: .invalidDataFormat))
        }

        guard fruitJSON["name"] != nil else {
            return (nil, DeserializationError(details: "Missing required 'name' key", type: .missingRequiredData))
        }

        guard let name = fruitJSON["name"] as? String else {
            return (nil, DeserializationError(details: "Expected value for 'name' key to be a string", type: .typeMismatch))
        }

        guard fruitJSON["description"] != nil else {
            return (nil, DeserializationError(details: "Missing required 'description' key", type: .missingRequiredData))
        }

        guard let description = fruitJSON["description"] as? String else {
            return (nil, DeserializationError(details: "Expected value for 'description' key to be a string", type: .typeMismatch))
        }

        guard fruitJSON["image"] != nil else {
            return (nil, DeserializationError(details: "Missing required 'image' key", type: .missingRequiredData))
        }

        guard let imageBase64String = fruitJSON["image"] as? String else {
            return (nil, DeserializationError(details: "Expected value for 'image' key to be a string", type: .typeMismatch))
        }

        let imageDataOpt = Data(base64Encoded: imageBase64String, options: Data.Base64DecodingOptions())

        guard let imageData = imageDataOpt else {
            return (nil, DeserializationError(details: "Image data returned by API is not valid base64", type: .invalidDataFormat))
        }

        guard let image = UIImage(data: imageData) else {
            return (nil, DeserializationError(details: "Base64 data returned by API is not a valid image", type: .invalidDataFormat))
        }

        let fruit = Fruit(name: name, description: description, image: image)
        return (fruit, nil)

    }
}
