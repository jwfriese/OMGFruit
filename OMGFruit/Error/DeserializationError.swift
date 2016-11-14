enum DeserializationErrorType {
    case missingRequiredData
    case invalidDataFormat
    case typeMismatch

    func description() -> String {
        switch(self) {
        case .missingRequiredData:
            return "MissingRequiredData"
        case .invalidDataFormat:
            return "InvalidDataFormat"
        case .typeMismatch:
            return "TypeMismatch"
        }
    }
}

struct DeserializationError: OMGError {
    fileprivate(set) var details: String
    fileprivate(set) var type: DeserializationErrorType

    init(details: String, type: DeserializationErrorType) {
        self.details = details
        self.type = type
    }
}

extension DeserializationError: Equatable { }

func ==(lhs: DeserializationError, rhs: DeserializationError) -> Bool {
    return lhs.details == rhs.details && lhs.type == rhs.type
}

extension DeserializationError: CustomStringConvertible {
    var description: String {
        get {
            return "DeserializationError { details: \"\(details)\", type: \"\(type.description())\" }"
        }
    }
}
