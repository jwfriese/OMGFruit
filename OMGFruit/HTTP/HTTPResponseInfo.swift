protocol HTTPResponseInfo {
    var statusCode: Int { get }
    var isSuccess: Bool { get }
}

struct HTTPResponseInfoImpl: HTTPResponseInfo {
    fileprivate(set) var statusCode: Int

    init(statusCode: Int) {
        self.statusCode = statusCode
    }

    var isSuccess: Bool {
        get {
            return statusCode >= 200 && statusCode < 300
        }
    }
}

