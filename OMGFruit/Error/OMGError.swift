protocol OMGError: Error, CustomStringConvertible {
    var details: String { get }
}
