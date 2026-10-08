import Foundation

struct PhoneNumber: Identifiable, Hashable, Sendable {
    let id: String
    let label: String
    let value: String

    init(label: String, value: String) {
        self.label = label
        self.value = value
        id = "\(label):\(value)"
    }

    var phoneURL: URL? {
        URL(string: "tel:\(dialableValue)")
    }

    var messageURL: URL? {
        URL(string: "sms:\(dialableValue)")
    }

    private var dialableValue: String {
        let allowedCharacters = CharacterSet(charactersIn: "+*#").union(.decimalDigits)
        return String(value.unicodeScalars.filter(allowedCharacters.contains))
    }
}

struct RecentContact: Identifiable, Hashable, Sendable {
    let id: String
    let givenName: String
    let familyName: String
    let displayName: String
    let phoneNumbers: [PhoneNumber]
    let createdAt: Date

    var primaryPhoneNumber: PhoneNumber? {
        phoneNumbers.first
    }

    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        var components = PersonNameComponents()
        components.givenName = givenName
        components.familyName = familyName

        let abbreviatedName = formatter.string(from: components)
        if !abbreviatedName.isEmpty {
            return abbreviatedName
                .split(separator: " ")
                .prefix(2)
                .compactMap(\.first)
                .map(String.init)
                .joined()
                .uppercased()
        }

        return String(displayName.prefix(1)).uppercased()
    }
}

struct ContactsSection: Identifiable, Sendable {
    let month: Date
    let contacts: [RecentContact]

    var id: Date { month }

    var title: String {
        month.formatted(.dateTime.month(.wide).year())
    }
}
