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

            describe("Deserializing fruit data where some of the data is invalid") {
                var fruit: Fruit?
                var deserializationError: DeserializationError?
                var imageBase64EncodedString: String!

                beforeEach {
                    let bundle = Bundle(for: type(of: self))
                    let testImageFilePath = bundle.path(forResource: "apple", ofType: "png")
                    let image = UIImage(contentsOfFile: testImageFilePath!)!
                    let imageData = UIImagePNGRepresentation(image)!
                    imageBase64EncodedString = imageData.base64EncodedString(options: NSData.Base64EncodingOptions())
                }

                context("Missing required 'name' field") {
                    beforeEach {
                        let partiallyValidAPIResponseJSON = [
                            "description": "a fruit like a turtle",
                            "image": imageBase64EncodedString,
                            ] as [String : Any]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidAPIResponseJSON, options: .prettyPrinted)
                        (fruit, deserializationError) = subject.deserialize(partiallyValidData)
                    }

                    it("returns a nil fruit") {
                        expect(fruit).to(beNil())
                    }

                    it("returns an error") {
                        expect(deserializationError).to(equal(DeserializationError(details: "Missing required 'name' key", type: .missingRequiredData)))
                    }
                }

                context("'name' field is not a string") {
                    beforeEach {
                        let partiallyValidAPIResponseJSON = [
                            "name": 1,
                            "description": "a fruit like a turtle",
                            "image": imageBase64EncodedString,
                            ] as [String : Any]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidAPIResponseJSON, options: .prettyPrinted)
                        (fruit, deserializationError) = subject.deserialize(partiallyValidData)
                    }

                    it("returns a nil fruit") {
                        expect(fruit).to(beNil())
                    }

                    it("returns an error") {
                        expect(deserializationError).to(equal(DeserializationError(details: "Expected value for 'name' key to be a string", type: .typeMismatch)))
                    }
                }

                context("Missing required 'description' field") {
                    beforeEach {
                        let partiallyValidAPIResponseJSON = [
                            "name": "turtle fruit",
                            "image": imageBase64EncodedString,
                            ] as [String : Any]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidAPIResponseJSON, options: .prettyPrinted)
                        (fruit, deserializationError) = subject.deserialize(partiallyValidData)
                    }

                    it("returns a nil fruit") {
                        expect(fruit).to(beNil())
                    }

                    it("returns an error") {
                        expect(deserializationError).to(equal(DeserializationError(details: "Missing required 'description' key", type: .missingRequiredData)))
                    }
                }

                context("'description' field is not a string") {
                    beforeEach {
                        let partiallyValidAPIResponseJSON = [
                            "name": "turtle fruit",
                            "description": 1,
                            "image": imageBase64EncodedString,
                            ] as [String : Any]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidAPIResponseJSON, options: .prettyPrinted)
                        (fruit, deserializationError) = subject.deserialize(partiallyValidData)
                    }

                    it("returns a nil fruit") {
                        expect(fruit).to(beNil())
                    }

                    it("returns an error") {
                        expect(deserializationError).to(equal(DeserializationError(details: "Expected value for 'description' key to be a string", type: .typeMismatch)))
                    }
                }

                context("Missing required 'image' field") {
                    beforeEach {
                        let partiallyValidAPIResponseJSON = [
                            "name": "turtle fruit",
                            "description": "a fruit like a turtle",
                            ] as [String : Any]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidAPIResponseJSON, options: .prettyPrinted)
                        (fruit, deserializationError) = subject.deserialize(partiallyValidData)
                    }

                    it("returns a nil fruit") {
                        expect(fruit).to(beNil())
                    }

                    it("returns an error") {
                        expect(deserializationError).to(equal(DeserializationError(details: "Missing required 'image' key", type: .missingRequiredData)))
                    }
                }

                context("'image' field is not a string") {
                    beforeEach {
                        let partiallyValidAPIResponseJSON = [
                            "name": "turtle fruit",
                            "description": "a fruit like a turtle",
                            "image": 1,
                            ] as [String : Any]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidAPIResponseJSON, options: .prettyPrinted)
                        (fruit, deserializationError) = subject.deserialize(partiallyValidData)
                    }

                    it("returns a nil fruit") {
                        expect(fruit).to(beNil())
                    }

                    it("returns an error") {
                        expect(deserializationError).to(equal(DeserializationError(details: "Expected value for 'image' key to be a string", type: .typeMismatch)))
                    }
                }

                context("'image' data is not valid base64") {
                    beforeEach {
                        let invalidBase64String = "not base64"

                        let partiallyValidAPIResponseJSON = [
                            "name": "turtle fruit",
                            "description": "a fruit like a turtle",
                            "image": invalidBase64String,
                            ] as [String : Any]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidAPIResponseJSON, options: .prettyPrinted)
                        (fruit, deserializationError) = subject.deserialize(partiallyValidData)
                    }

                    it("returns a nil fruit") {
                        expect(fruit).to(beNil())
                    }

                    it("returns an error") {
                        expect(deserializationError).to(equal(DeserializationError(details: "Image data returned by API is not valid base64", type: .invalidDataFormat)))
                    }
                }

                context("'image' data is valid base64 and not valid PNG data") {
                    beforeEach {
                        let nonImageData = "some nonimage string".data(using: String.Encoding.utf8)!
                        let nonImageBase64String = nonImageData.base64EncodedString(options: Data.Base64EncodingOptions())

                        let partiallyValidAPIResponseJSON = [
                            "name": "turtle fruit",
                            "description": "a fruit like a turtle",
                            "image": nonImageBase64String,
                            ] as [String : Any]

                        let partiallyValidData = try! JSONSerialization.data(withJSONObject: partiallyValidAPIResponseJSON, options: .prettyPrinted)
                        (fruit, deserializationError) = subject.deserialize(partiallyValidData)
                    }

                    it("returns a nil fruit") {
                        expect(fruit).to(beNil())
                    }

                    it("returns an error") {
                        expect(deserializationError).to(equal(DeserializationError(details: "Base64 data returned by API is not a valid image", type: .invalidDataFormat)))
                    }
                }
            }
        }
    }
}

