import Contacts
import Foundation

enum ContactsViewState: Equatable {
    case loading
    case loaded
    case permissionDenied
    case failed(String)
}

private struct ContactSnapshot: Sendable {
    let identifier: String
    let givenName: String
    let familyName: String
    let displayName: String
    let phoneNumbers: [PhoneNumber]
}

private actor ContactsService {
    private let contactStore = CNContactStore()

    func authorizationStatus() -> CNAuthorizationStatus {
        CNContactStore.authorizationStatus(for: .contacts)
    }

    func requestAccess() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            contactStore.requestAccess(for: .contacts) { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func fetchContacts() throws -> [ContactSnapshot] {
        let keys: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]
        let request = CNContactFetchRequest(keysToFetch: keys)
        request.sortOrder = .userDefault

        var contacts: [ContactSnapshot] = []
        try contactStore.enumerateContacts(with: request) { contact, _ in
            let phoneNumbers = contact.phoneNumbers.map { labeledValue in
                PhoneNumber(
                    label: CNLabeledValue<NSString>.localizedString(forLabel: labeledValue.label ?? CNLabelPhoneNumberMain),
                    value: labeledValue.value.stringValue
                )
            }

            guard !phoneNumbers.isEmpty else { return }

            let formattedName = CNContactFormatter.string(from: contact, style: .fullName)
            let fallbackName = phoneNumbers[0].value
            let displayName = formattedName.flatMap { $0.isEmpty ? nil : $0 } ?? fallbackName
            contacts.append(
                ContactSnapshot(
                    identifier: contact.identifier,
                    givenName: contact.givenName,
                    familyName: contact.familyName,
                    displayName: displayName,
                    phoneNumbers: phoneNumbers
                )
            )
        }

        return contacts
    }

    func deleteContact(identifier: String) throws {
        let contact = try contactStore.unifiedContact(
            withIdentifier: identifier,
            keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor]
        )
        guard let mutableContact = contact.mutableCopy() as? CNMutableContact else {
            throw ContactsStoreError.couldNotDelete
        }

        let request = CNSaveRequest()
        request.delete(mutableContact)
        try contactStore.execute(request)
    }
}

private enum ContactsStoreError: LocalizedError {
    case couldNotDelete

    var errorDescription: String? {
        String(localized: "The contact could not be deleted.")
    }
}

@MainActor
final class ContactsStore: ObservableObject {
    @Published private(set) var sections: [ContactsSection] = []
    @Published private(set) var state: ContactsViewState = .loading

    private let service = ContactsService()
    private let defaults: UserDefaults
    private let firstSeenKey = "contactFirstSeenDates"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() async {
        if sections.isEmpty {
            state = .loading
        }

        do {
            var status = await service.authorizationStatus()
            if status == .notDetermined {
                let granted = try await service.requestAccess()
                if !granted {
                    state = .permissionDenied
                    return
                }
                status = await service.authorizationStatus()
            }

            guard Self.canReadContacts(status) else {
                sections = []
                state = .permissionDenied
                return
            }

            let snapshots = try await service.fetchContacts()
            sections = makeSections(from: snapshots)
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func delete(_ contact: RecentContact) async {
        do {
            try await service.deleteContact(identifier: contact.id)
            removeStoredDate(for: contact.id)
            await load()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private static func canReadContacts(_ status: CNAuthorizationStatus) -> Bool {
        if status == .authorized {
            return true
        }

        if #available(iOS 18.0, *), status == .limited {
            return true
        }

        return false
    }

    private func makeSections(from snapshots: [ContactSnapshot]) -> [ContactsSection] {
        let now = Date()
        var firstSeenDates = defaults.dictionary(forKey: firstSeenKey) as? [String: TimeInterval] ?? [:]
        let currentIdentifiers = Set(snapshots.map(\.identifier))
        firstSeenDates = firstSeenDates.filter { currentIdentifiers.contains($0.key) }

        let contacts = snapshots.map { snapshot in
            let timestamp = firstSeenDates[snapshot.identifier] ?? now.timeIntervalSince1970
            firstSeenDates[snapshot.identifier] = timestamp
            return RecentContact(
                id: snapshot.identifier,
                givenName: snapshot.givenName,
                familyName: snapshot.familyName,
                displayName: snapshot.displayName,
                phoneNumbers: snapshot.phoneNumbers,
                firstSeenAt: Date(timeIntervalSince1970: timestamp)
            )
        }
        defaults.set(firstSeenDates, forKey: firstSeenKey)

        let calendar = Calendar.autoupdatingCurrent
        let grouped = Dictionary(grouping: contacts) { contact in
            let components = calendar.dateComponents([.year, .month], from: contact.firstSeenAt)
            return calendar.date(from: components) ?? calendar.startOfDay(for: contact.firstSeenAt)
        }

        return grouped
            .map { month, contacts in
                ContactsSection(
                    month: month,
                    contacts: contacts.sorted {
                        if $0.firstSeenAt != $1.firstSeenAt {
                            return $0.firstSeenAt > $1.firstSeenAt
                        }
                        return $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending
                    }
                )
            }
            .sorted { $0.month > $1.month }
    }

    private func removeStoredDate(for identifier: String) {
        var firstSeenDates = defaults.dictionary(forKey: firstSeenKey) as? [String: TimeInterval] ?? [:]
        firstSeenDates.removeValue(forKey: identifier)
        defaults.set(firstSeenDates, forKey: firstSeenKey)
    }
}
