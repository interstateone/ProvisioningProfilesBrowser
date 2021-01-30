import Foundation

func configure<Subject>(_ subject: Subject, configure: (inout Subject) -> Void) -> Subject {
    var copy = subject
    configure(&copy)
    return copy
}
