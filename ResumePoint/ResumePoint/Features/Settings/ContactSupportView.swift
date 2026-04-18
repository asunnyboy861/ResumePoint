import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSubject: FeedbackSubject = .general
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    private let feedbackURL = "https://feedback-board.iocompile67692.workers.dev/api/feedback"
    private let appName = "ResumePoint"

    var body: some View {
        Form {
            subjectSection
            nameSection
            emailSection
            messageSection
            submitSection
        }
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thank You!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your feedback has been submitted successfully. We will get back to you soon.")
        }
        .alert("Submission Failed", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var subjectSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Topic")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 100, maximum: 160), spacing: 8)
                ], spacing: 8) {
                    ForEach(FeedbackSubject.allCases) { subject in
                        SubjectChip(
                            subject: subject,
                            isSelected: selectedSubject == subject
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedSubject = subject
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var nameSection: some View {
        Section {
            HStack {
                Image(systemName: "person")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                TextField("Your Name", text: $name)
            }
        }
    }

    private var emailSection: some View {
        Section {
            HStack {
                Image(systemName: "envelope")
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                TextField("Email Address", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
    }

    private var messageSection: some View {
        Section {
            ZStack(alignment: .topLeading) {
                if message.isEmpty {
                    Text("Describe your issue or feedback...")
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                TextEditor(text: $message)
                    .frame(minHeight: 120)
            }
        } header: {
            Text("Message")
        }
    }

    private var submitSection: some View {
        Section {
            Button(action: submitFeedback) {
                HStack {
                    Spacer()
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Submit Feedback")
                            .font(.headline)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.accentColor)
            .foregroundStyle(.white)
            .disabled(isSubmitting || !isValid)
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && !email.trimmingCharacters(in: .whitespaces).isEmpty
        && email.contains("@")
        && !message.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submitFeedback() {
        guard isValid else { return }
        isSubmitting = true
        errorMessage = nil

        let requestBody: [String: String] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "email": email.trimmingCharacters(in: .whitespaces),
            "subject": selectedSubject.displayName,
            "message": message.trimmingCharacters(in: .whitespaces),
            "app_name": appName
        ]

        guard let url = URL(string: feedbackURL) else {
            errorMessage = "Invalid server URL."
            isSubmitting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 30

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false

                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid server response."
                    return
                }

                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let success = json["success"] as? Bool, success {
                        showSuccess = true
                        return
                    }
                    showSuccess = true
                } else {
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = json["error"] as? String {
                        errorMessage = error
                    } else {
                        errorMessage = "Server error (\(httpResponse.statusCode)). Please try again."
                    }
                }
            }
        }.resume()
    }
}

enum FeedbackSubject: String, CaseIterable, Identifiable {
    case bug = "bug"
    case feature = "feature"
    case question = "question"
    case performance = "performance"
    case ui = "ui"
    case general = "general"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bug: return "Bug Report"
        case .feature: return "Feature Request"
        case .question: return "Question"
        case .performance: return "Performance"
        case .ui: return "UI Issue"
        case .general: return "General"
        }
    }

    var icon: String {
        switch self {
        case .bug: return "ladybug"
        case .feature: return "lightbulb"
        case .question: return "questionmark.circle"
        case .performance: return "gauge.with.dots.needle.67percent"
        case .ui: return "paintbrush"
        case .general: return "text.bubble"
        }
    }
}

struct SubjectChip: View {
    let subject: FeedbackSubject
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: subject.icon)
                    .font(.caption2)
                Text(subject.displayName)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ContactSupportView()
    }
}
