import Foundation

enum ExportFormat: String, CaseIterable, Identifiable {
    case json = "json"
    case csv = "csv"
    case pdf = "pdf"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .json: return "JSON"
        case .csv: return "CSV"
        case .pdf: return "PDF"
        }
    }

    var fileExtension: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .json: return "curlybraces"
        case .csv: return "tablecells"
        case .pdf: return "doc.richtext"
        }
    }

    var mimeType: String {
        switch self {
        case .json: return "application/json"
        case .csv: return "text/csv"
        case .pdf: return "application/pdf"
        }
    }
}
