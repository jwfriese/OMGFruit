import XCTest
import Quick
import Nimble
@testable import OMGFruit

class HTTPResponseInfoImplSpec: QuickSpec {
    override func spec() {
        describe("HTTPResponseInfoImpl") {
            describe("isSuccess") {
                context("When 200-type status code") {
                    it("returns true") {
                        expect(HTTPResponseInfoImpl(statusCode: 200).isSuccess).to(beTrue())
                        expect(HTTPResponseInfoImpl(statusCode: 201).isSuccess).to(beTrue())
                        expect(HTTPResponseInfoImpl(statusCode: 210).isSuccess).to(beTrue())
                        expect(HTTPResponseInfoImpl(statusCode: 299).isSuccess).to(beTrue())
                    }
                }

                context("When any other status code") {
                    it("returns false") {
                        expect(HTTPResponseInfoImpl(statusCode: 100).isSuccess).to(beFalse())
                        expect(HTTPResponseInfoImpl(statusCode: 300).isSuccess).to(beFalse())
                        expect(HTTPResponseInfoImpl(statusCode: 400).isSuccess).to(beFalse())
                        expect(HTTPResponseInfoImpl(statusCode: 500).isSuccess).to(beFalse())
                    }
                }
            }
        }
    }
}
