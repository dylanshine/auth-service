extension Array where Element == UInt8 {
    static func generate(bits: Int) -> String {
        random(count: bits / 8).hex
    }
}
