import XCTest
import Quick
import Nimble
import Fleet

@testable import OMGFruit

class FruitServiceSpec: QuickSpec {

    class MockHTTPClient: HTTPClient {
        var capturedRequest: URLRequest?
        var capturedCompletion: ((Data?, HTTPResponseInfo?, OMGError?) -> ())?

        override func doRequest(_ request: URLRequest, completion: ((Data?, HTTPResponseInfo?, OMGError?) -> ())?) {
            capturedRequest = request
            capturedCompletion = completion
        }
    }

    class MockFruitDeserializer: FruitDeserializer {
        var capturedData: Data?
        var fruitToReturn: Fruit?
        var errorToReturn: DeserializationError?

        override func deserialize(_ data: Data) -> (fruit: Fruit?, error: DeserializationError?) {
            capturedData = data
            return (fruitToReturn, errorToReturn)
        }
    }

    override func spec() {
        describe("FruitService") {
            var subject: FruitService!
            var mockHTTPClient: MockHTTPClient!
            var mockFruitDeserializer: MockFruitDeserializer!

            beforeEach {
                subject = FruitService()

                mockHTTPClient = MockHTTPClient()
                subject.httpClient = mockHTTPClient

                mockFruitDeserializer = MockFruitDeserializer()
                subject.fruitDeserializer = mockFruitDeserializer
            }

            describe("Getting a fruit") {
                var returnedFruit: Fruit?
                var returnedError: OMGError?

                beforeEach {
                    subject.getFruit() { fruit, error in
                        returnedFruit = fruit
                        returnedError = error
                    }
                }

                it("uses the HTTPClient to make a call to the fruit API") {
                    guard let capturedRequest = mockHTTPClient.capturedRequest else {
                        fail("Failed to make a call using the HTTPClient")
                        return
                    }

                    expect(capturedRequest.httpMethod).to(equal("GET"))
                    expect(capturedRequest.allHTTPHeaderFields?["Content-Type"]).to(equal("application/json"))
                    expect(capturedRequest.url?.absoluteString).to(equal("http://localhost:8080/fruit"))
                }

                describe("When the API call resolves with a fruit and no error") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass a completion handler to the HTTPClient")
                            return
                        }

                        let bundle = Bundle(for: type(of: self))
                        let testImageFilePath = bundle.path(forResource: "apple", ofType: "png")
                        let image = UIImage(contentsOfFile: testImageFilePath!)!
                        let data = "valid API response".data(using: String.Encoding.utf8)

                        let fruit = Fruit(name: "turtle fruit", description: "a fruit fit for a turtle", image: image)
                        mockFruitDeserializer.fruitToReturn = fruit
                        mockFruitDeserializer.errorToReturn = nil

                        completion(data, HTTPResponseInfoImpl(statusCode: 200), nil)
                    }

                    it("passes the data along to the deserializer") {
                        expect(mockFruitDeserializer.capturedData).to(equal("valid API response".data(using: String.Encoding.utf8)))
                    }

                    it("calls its completion handler with the fruit produced by the fruit deserializer") {
                        guard let returnedFruit = returnedFruit else {
                            fail("Failed to return fruit from deserializer")
                            return
                        }

                        expect(returnedFruit.name).to(equal("turtle fruit"))
                        expect(returnedFruit.description).to(equal("a fruit fit for a turtle"))

                        let bundle = Bundle(for: type(of: self))
                        let testImageFilePath = bundle.path(forResource: "apple", ofType: "png")
                        let expectedImage = UIImage(contentsOfFile: testImageFilePath!)!
                        let expectedImageData = UIImagePNGRepresentation(expectedImage)
                        let actualImageData = UIImagePNGRepresentation(returnedFruit.image)
                        expect(actualImageData).to(equal(expectedImageData))
                    }

                    it("calls its completion handler with no error") {
                        expect(returnedError).to(beNil())
                    }
                }

                describe("When the API call resolves with a success response and deserialization errors") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to the HTTPClient")
                            return
                        }

                        mockFruitDeserializer.errorToReturn = DeserializationError(details: "error details", type: .invalidInputFormat)

                        let invalidBuildsData = "invalid fruit data".data(using: String.Encoding.utf8)
                        completion(invalidBuildsData, HTTPResponseInfoImpl(statusCode: 200), nil)
                    }

                    it("passes the data along to the deserializer") {
                        let expectedData = "invalid fruit data".data(using: String.Encoding.utf8)
                        expect(mockFruitDeserializer.capturedData).to(equal(expectedData))
                    }

                    it("calls its completion handler nil with a nil fruit") {
                        expect(returnedFruit).to(beNil())
                    }

                    it("calls its completion handler with the error that comes from the deserializer") {
                        expect(returnedError as? DeserializationError).to(equal(DeserializationError(details: "error details", type: .invalidInputFormat)))
                    }
                }

                describe("When the API call resolves with an error") {
                    beforeEach {
                        guard let completion = mockHTTPClient.capturedCompletion else {
                            fail("Failed to pass completion handler to the HTTPClient")
                            return
                        }

                        completion(nil, HTTPResponseInfoImpl(statusCode: 500), BasicError(details: "error details"))
                    }

                    it("calls its completion handler with a nil fruit") {
                        expect(returnedFruit).to(beNil())
                    }

                    it("calls its completion handler with the error that came back from the request") {
                        expect(returnedError as? BasicError).to(equal(BasicError(details: "error details")))
                    }
                }
            }
        }
    }
}
