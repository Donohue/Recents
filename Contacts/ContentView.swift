import SwiftUI

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var contactsStore: ContactsStore

    @State private var callCandidate: RecentContact?
    @State private var deleteCandidate: RecentContact?

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Recents")
        }
        .navigationViewStyle(.stack)
        .task {
            await contactsStore.load()
        }
        .onChange(of: scenePhase) { phase in
            guard phase == .active else { return }
            Task { await contactsStore.load() }
        }
        .alert("Call contact?", isPresented: callAlertIsPresented, presenting: callCandidate) { contact in
            Button("Cancel", role: .cancel) {}
            Button("Call") {
                if let url = contact.primaryPhoneNumber?.phoneURL {
                    openURL(url)
                }
            }
        } message: { contact in
            Text(contact.primaryPhoneNumber?.value ?? contact.displayName)
        }
        .confirmationDialog(
            "Delete contact?",
            isPresented: deleteDialogIsPresented,
            titleVisibility: .visible,
            presenting: deleteCandidate
        ) { contact in
            Button("Delete \(contact.displayName)", role: .destructive) {
                Task { await contactsStore.delete(contact) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { contact in
            Text("This removes \(contact.displayName) from Contacts on all synced devices.")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch contactsStore.state {
        case .loading:
            ProgressView("Loading contacts…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
        case .permissionDenied:
            PermissionView()
        case let .failed(message):
            StatusView(
                icon: "exclamationmark.triangle.fill",
                title: "Unable to Load Contacts",
                message: message,
                actionTitle: "Try Again"
            ) {
                Task { await contactsStore.load() }
            }
        case .loaded:
            if contactsStore.sections.isEmpty {
                StatusView(
                    icon: "person.crop.circle.badge.questionmark",
                    title: "No Phone Contacts",
                    message: "Contacts with a phone number will appear here.",
                    actionTitle: "Refresh"
                ) {
                    Task { await contactsStore.load() }
                }
            } else {
                contactsList
            }
        }
    }

    private var contactsList: some View {
        List {
            ForEach(contactsStore.sections) { section in
                Section(section.title) {
                    ForEach(section.contacts) { contact in
                        ContactRow(
                            contact: contact,
                            callAction: { callCandidate = contact },
                            messageAction: {
                                if let url = contact.primaryPhoneNumber?.messageURL {
                                    openURL(url)
                                }
                            }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteCandidate = contact
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await contactsStore.load()
        }
    }

    private var callAlertIsPresented: Binding<Bool> {
        Binding(
            get: { callCandidate != nil },
            set: { if !$0 { callCandidate = nil } }
        )
    }

    private var deleteDialogIsPresented: Binding<Bool> {
        Binding(
            get: { deleteCandidate != nil },
            set: { if !$0 { deleteCandidate = nil } }
        )
    }
}

private struct ContactRow: View {
    let contact: RecentContact
    let callAction: () -> Void
    let messageAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(contact.initials)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tint)
                .frame(width: 40, height: 40)
                .background(Color.accentColor.opacity(0.14), in: Circle())
                .accessibilityHidden(true)

            Text(contact.displayName)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer(minLength: 8)

            actionButton("message.fill", label: "Message \(contact.displayName)", action: messageAction)
            actionButton("phone.fill", label: "Call \(contact.displayName)", action: callAction)
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle())
    }

    private func actionButton(_ systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .frame(width: 34, height: 34)
                .background(Color.accentColor.opacity(0.12), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private struct PermissionView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        StatusView(
            icon: "person.crop.circle.badge.exclamationmark",
            title: "Contacts Access Needed",
            message: "Allow Recents to read your contacts so it can show people with phone numbers.",
            actionTitle: "Open Settings"
        ) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            openURL(url)
        }
    }
}

private struct StatusView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 54, weight: .light))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button(actionTitle, action: action)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
