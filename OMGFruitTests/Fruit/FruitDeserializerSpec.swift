import XCTest
import Quick
import Nimble

@testable import OMGFruit

class FruitDeserializerSpec: QuickSpec {
    override func spec() {
        describe("FruitDeserializer") {
            var subject: FruitDeserializer!

            beforeEach {
                subject = FruitDeserializer()
            }

            describe("When all required fruit data is present and valid in given data") {
                var fruit: Fruit?
                var deserializationError: DeserializationError?

                beforeEach {
                    let bundle = Bundle(for: type(of: self))
                    let testImageFilePath = bundle.path(forResource: "apple", ofType: "png")
                    let image = UIImage(contentsOfFile: testImageFilePath!)!
                    let imageData = UIImagePNGRepresentation(image)!
                    let imageBase64EncodedString = imageData.base64EncodedString(options: NSData.Base64EncodingOptions())

                    let validAPIResponseJSON = [
                        "name": "turtle fruit",
                        "description": "a fruit like a turtle",
                        "image": imageBase64EncodedString,
                    ] as [String : Any]

                    let validAPIResponseData = try! JSONSerialization.data(withJSONObject: validAPIResponseJSON, options: .prettyPrinted)
                    (fruit, deserializationError) = subject.deserialize(validAPIResponseData)
                }

                it("returns no error") {
                    expect(deserializationError).to(beNil())
                }

                it("returns a fruit") {
                    guard let fruit = fruit else {
                        fail("Expected to have a Fruit returned")
                        return
                    }

                    expect(fruit.name).to(equal("turtle fruit"))
                    expect(fruit.description).to(equal("a fruit like a turtle"))

                    let bundle = Bundle(for: type(of: self))
                    let testImageFilePath = bundle.path(forResource: "apple", ofType: "png")
                    let image = UIImage(contentsOfFile: testImageFilePath!)!
                    let expectedImageData = UIImagePNGRepresentation(image)!
                    let actualImageData = UIImagePNGRepresentation(fruit.image)

                    expect(actualImageData).to(equal(expectedImageData))
                }
            }
        }
    }
}

