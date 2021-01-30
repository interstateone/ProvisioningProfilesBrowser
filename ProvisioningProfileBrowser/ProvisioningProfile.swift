import Foundation

@objcMembers
class ProvisioningProfile: NSObject {
    var url: URL
    var uuid: String
    var name: String
    var teamName: String
    var creationDate: Date
    var expirationDate: Date

    init(
        url: URL,
        uuid: String,
        name: String,
        teamName: String,
        creationDate: Date,
        expirationDate: Date
    ) {
        self.url = url
        self.uuid = uuid
        self.name = name
        self.teamName = teamName
        self.creationDate = creationDate
        self.expirationDate = expirationDate
    }
}

extension ProvisioningProfile: Identifiable {
    public var id: String { uuid }
}

extension ProvisioningProfile {
    static func == (lhs: ProvisioningProfile, rhs: ProvisioningProfile) -> Bool {
        lhs.url == rhs.url &&
            lhs.uuid == rhs.uuid &&
            lhs.name == rhs.name &&
            lhs.teamName == rhs.teamName &&
            lhs.creationDate == rhs.creationDate &&
            lhs.expirationDate == rhs.expirationDate
    }
}
