import SwiftUI

struct PasswordSignUpScreen: View {
    @Environment(SessionCoordinator.self) private var session
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case username
        case password
        case confirmPassword
    }

    private var trimmedUsername: String { username.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var passwordsMatch: Bool { password == confirmPassword }
    private var isPasswordLongEnough: Bool { password.count >= 8 }
    private var showsPasswordLengthError: Bool { !password.isEmpty && !isPasswordLongEnough }
    private var showsMismatchError: Bool { !confirmPassword.isEmpty && !passwordsMatch }
    private var canSubmit: Bool { !trimmedUsername.isEmpty && isPasswordLongEnough && passwordsMatch }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    AuthHeader(
                        title: "Create account",
                        description: "Choose a username and password for your Sverto server.",
                        systemImage: "person.badge.plus"
                    )
                }
                Section {
                    HStack(spacing: 10) {
                        Image(systemName: "person")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Username")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            TextField("Username", text: $username)
                                .textContentType(.username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .submitLabel(.next)
                                .focused($focusedField, equals: .username)
                                .onSubmit { focusedField = .password }
                        }
                    }
                }
                Section {
                    HStack(spacing: 10) {
                        Image(systemName: "lock")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Password")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            SecureField("Password", text: $password)
                                .textContentType(.newPassword)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .submitLabel(.next)
                                .focused($focusedField, equals: .password)
                                .onSubmit { focusedField = .confirmPassword }
                        }
                    }
                    HStack(spacing: 10) {
                        Image(systemName: "lock.rotation")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Confirm password")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            SecureField("Confirm password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .submitLabel(.done)
                                .focused($focusedField, equals: .confirmPassword)
                                .onSubmit(submit)
                        }
                    }
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("At least 8 characters")
                            .foregroundStyle(showsPasswordLengthError ? .red : .secondary)
                        if showsMismatchError {
                            Text("Passwords don't match")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    ProminentActionButton(title: "Create account", action: submit)
                        .disabled(!canSubmit)
                    Button("Back") { session.showSignIn() }
                        .frame(minHeight: 44)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
        }
    }

    private func submit() {
        guard canSubmit else { return }
        focusedField = nil
        session.signUp(username: trimmedUsername, password: password)
    }
}
