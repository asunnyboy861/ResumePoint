import SwiftUI

struct ExportFormatPicker: View {
    @Binding var selectedFormat: ExportFormat
    @Environment(\.dismiss) private var dismiss
    var onExport: (ExportFormat) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(ExportFormat.allCases) { format in
                    ExportFormatRow(
                        format: format,
                        isSelected: selectedFormat == format,
                        onTap: {
                            selectFormat(format)
                        }
                    )
                }
            }
            .navigationTitle("Export Format")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func selectFormat(_ format: ExportFormat) {
        selectedFormat = format
        onExport(format)
        dismiss()
    }
}

struct ExportFormatRow: View {
    let format: ExportFormat
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Label(format.displayName, systemImage: format.icon)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExportFormatPicker(selectedFormat: .constant(.json)) { _ in }
}
