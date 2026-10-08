@preconcurrency import AddressBook
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
    let creationDate: Date?
}

private actor ContactsService {
    func authorizationStatus() -> ABAuthorizationStatus {
        ABAddressBookGetAuthorizationStatus()
    }

    func requestAccess() async throws -> Bool {
        let addressBook = try makeAddressBook()
        return try await withCheckedThrowingContinuation { continuation in
            ABAddressBookRequestAccessWithCompletion(addressBook) { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func fetchContacts() throws -> [ContactSnapshot] {
        let addressBook = try makeAddressBook()
        guard let people = ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeRetainedValue() as? [ABRecord] else {
            return []
        }

        return people.compactMap { record in
            let phoneNumbers = phoneNumbers(for: record)
            guard !phoneNumbers.isEmpty else { return nil }

            let givenName = stringValue(for: record, property: kABPersonFirstNameProperty) ?? ""
            let familyName = stringValue(for: record, property: kABPersonLastNameProperty) ?? ""
            let displayName = compositeName(for: record) ?? phoneNumbers[0].value

            return ContactSnapshot(
                identifier: String(ABRecordGetRecordID(record)),
                givenName: givenName,
                familyName: familyName,
                displayName: displayName,
                phoneNumbers: phoneNumbers,
                creationDate: dateValue(for: record, property: kABPersonCreationDateProperty)
            )
        }
    }

    func deleteContact(identifier: String) throws {
        guard let recordID = ABRecordID(identifier) else {
            throw ContactsStoreError.couldNotDelete
        }

        let addressBook = try makeAddressBook()
        guard let unmanagedPerson = ABAddressBookGetPersonWithRecordID(addressBook, recordID) else {
            throw ContactsStoreError.couldNotDelete
        }
        let person = unmanagedPerson.takeUnretainedValue()

        guard ABAddressBookRemoveRecord(addressBook, person, nil),
              ABAddressBookSave(addressBook, nil) else {
            throw ContactsStoreError.couldNotDelete
        }
    }

    private func makeAddressBook() throws -> ABAddressBook {
        guard let addressBook = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue() else {
            throw ContactsStoreError.couldNotOpenAddressBook
        }
        return addressBook
    }

    private func stringValue(for record: ABRecord, property: ABPropertyID) -> String? {
        guard let value = ABRecordCopyValue(record, property)?.takeRetainedValue() else { return nil }
        return value as? String
    }

    private func dateValue(for record: ABRecord, property: ABPropertyID) -> Date? {
        guard let value = ABRecordCopyValue(record, property)?.takeRetainedValue() else { return nil }
        return value as? Date
    }

    private func compositeName(for record: ABRecord) -> String? {
        guard let name = ABRecordCopyCompositeName(record)?.takeRetainedValue() as String?, !name.isEmpty else {
            return nil
        }
        return name
    }

    private func phoneNumbers(for record: ABRecord) -> [PhoneNumber] {
        guard let value = ABRecordCopyValue(record, kABPersonPhoneProperty)?.takeRetainedValue() else {
            return []
        }
        let phoneNumbers: ABMultiValue = value

        return (0..<ABMultiValueGetCount(phoneNumbers)).compactMap { index in
            guard let value = ABMultiValueCopyValueAtIndex(phoneNumbers, index)?.takeRetainedValue() as? String else {
                return nil
            }

            let label: String
            if let rawLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, index)?.takeRetainedValue(),
               let localizedLabel = ABAddressBookCopyLocalizedLabel(rawLabel)?.takeRetainedValue() {
                label = localizedLabel as String
            } else {
                label = String(localized: "Phone")
            }

            return PhoneNumber(label: label, value: value)
        }
    }
}

private enum ContactsStoreError: LocalizedError {
    case couldNotOpenAddressBook
    case couldNotDelete

    var errorDescription: String? {
        switch self {
        case .couldNotOpenAddressBook:
            String(localized: "The contacts database could not be opened.")
        case .couldNotDelete:
            String(localized: "The contact could not be deleted.")
        }
    }
}

@MainActor
final class ContactsStore: ObservableObject {
    @Published private(set) var sections: [ContactsSection] = []
    @Published private(set) var state: ContactsViewState = .loading

    private let service = ContactsService()
    private let defaults: UserDefaults
    private let fallbackDatesKey = "contactFallbackDates"

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

            guard status == .authorized else {
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
            removeFallbackDate(for: contact.id)
            await load()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func makeSections(from snapshots: [ContactSnapshot]) -> [ContactsSection] {
        let now = Date()
        var fallbackDates = defaults.dictionary(forKey: fallbackDatesKey) as? [String: TimeInterval] ?? [:]
        let currentIdentifiers = Set(snapshots.map(\.identifier))
        fallbackDates = fallbackDates.filter { currentIdentifiers.contains($0.key) }

        let contacts = snapshots.map { snapshot in
            let fallbackTimestamp = fallbackDates[snapshot.identifier] ?? now.timeIntervalSince1970
            if snapshot.creationDate == nil {
                fallbackDates[snapshot.identifier] = fallbackTimestamp
            } else {
                fallbackDates.removeValue(forKey: snapshot.identifier)
            }

            return RecentContact(
                id: snapshot.identifier,
                givenName: snapshot.givenName,
                familyName: snapshot.familyName,
                displayName: snapshot.displayName,
                phoneNumbers: snapshot.phoneNumbers,
                createdAt: snapshot.creationDate ?? Date(timeIntervalSince1970: fallbackTimestamp)
            )
        }
        defaults.set(fallbackDates, forKey: fallbackDatesKey)

        let calendar = Calendar.autoupdatingCurrent
        let grouped = Dictionary(grouping: contacts) { contact in
            let components = calendar.dateComponents([.year, .month], from: contact.createdAt)
            return calendar.date(from: components) ?? calendar.startOfDay(for: contact.createdAt)
        }

        return grouped
            .map { month, contacts in
                ContactsSection(
                    month: month,
                    contacts: contacts.sorted {
                        if $0.createdAt != $1.createdAt {
                            return $0.createdAt > $1.createdAt
                        }
                        return $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending
                    }
                )
            }
            .sorted { $0.month > $1.month }
    }

    private func removeFallbackDate(for identifier: String) {
        var fallbackDates = defaults.dictionary(forKey: fallbackDatesKey) as? [String: TimeInterval] ?? [:]
        fallbackDates.removeValue(forKey: identifier)
        defaults.set(fallbackDates, forKey: fallbackDatesKey)
    }
}
