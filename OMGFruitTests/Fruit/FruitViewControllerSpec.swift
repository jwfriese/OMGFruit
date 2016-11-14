import XCTest
import Quick
import Nimble
import Fleet
@testable import OMGFruit

class FruitViewControllerSpec: QuickSpec {
    override func spec() {
        class MockFruitService: FruitService {
            var capturedCompletion: ((Fruit?, OMGError?) -> ())?

            override func getFruit(_ completion: ((Fruit?, OMGError?) -> ())?) {
                capturedCompletion = completion
            }
        }

        describe("FruitViewController") {
            var subject: FruitViewController!
            var mockFruitService: MockFruitService!

            beforeEach {
                let storyboard = UIStoryboard(name: "Fruit", bundle: nil)
                subject = storyboard.instantiateInitialViewController() as! FruitViewController

                mockFruitService = MockFruitService()
                subject.fruitService = mockFruitService
            }

            describe("After the view has loaded") {
                beforeEach {
                    Fleet.setApplicationWindowRootViewController(subject)
                }

                describe("Tapping the 'Fruit, please' button") {
                    beforeEach {
                        subject.getFruitButton?.tap()
                    }

                    it("disables the button") {
                        expect(subject.getFruitButton?.isEnabled).to(beFalse())
                    }

                    describe("When the fruit service returns a fruit") {
                        var returnedFruit: Fruit!
                        var mockFruitImage: UIImage!

                        beforeEach {
                            let bundle = Bundle(for: type(of: self))
                            let imagePath = bundle.path(forResource: "apple", ofType: "png")
                            mockFruitImage = UIImage(contentsOfFile: imagePath!)
                            returnedFruit = Fruit(name: "turtle fruit", description: "a fruit like a turtle", image: mockFruitImage)
                            guard let completion = mockFruitService.capturedCompletion else {
                                fail("Failed to pass a completion handler to the FruitService")
                                return
                            }

                            completion(returnedFruit, nil)
                        }

                        it("enable the 'Fruit, please' button") {
                            expect(subject.getFruitButton?.isEnabled).toEventually(beTrue())
                        }

                        it("sets the image view's content to the returned image") {
                            expect(subject.fruitImageView?.image).toEventually(equal(mockFruitImage))
                        }

                        it("sets the fruit summary label's content to the returned fruit description") {
                            expect(subject.fruitSummaryLabel?.text).toEventually(equal("a fruit like a turtle"))
                        }
                    }

                    describe("When the fruit service returns an error") {
                        beforeEach {
                            guard let completion = mockFruitService.capturedCompletion else {
                                fail("Failed to pass a completion handler to the FruitService")
                                return
                            }

                            completion(nil, BasicError(details: "failed to get fruit"))
                        }

                        it("displays an alert containing the error that came from the HTTP call") {
                            expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))

                            let screen = Fleet.getApplicationScreen()
                            expect(screen?.topmostViewController).toEventually(beAKindOf(UIAlertController.self))

                            let alert = screen?.topmostViewController as? UIAlertController
                            expect(alert?.title).toEventually(equal("OMG NO"))
                            expect(alert?.message).toEventually(equal("failed to get fruit"))
                        }
                    }
                }
            }
        }
    }
}
