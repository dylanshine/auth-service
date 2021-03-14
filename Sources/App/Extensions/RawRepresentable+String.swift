import Vapor
import Fluent

extension RawRepresentable where RawValue == String {
    var fieldKey: FieldKey {
        return .string(rawValue)
    }
    
    var resource: PathComponent {
        return .constant(rawValue)
    }
    
    var parameter: PathComponent {
        return .parameter(rawValue)
    }
}
