import Foundation
import PDFKit

protocol ExportServicing {
    func export(videos: [VideoProgress], format: ExportFormat) async throws -> Data
    func generateCSV(from videos: [VideoProgress]) -> Data
    func generatePDF(from videos: [VideoProgress]) -> Data
}

final class ExportService: ExportServicing {

    func export(videos: [VideoProgress], format: ExportFormat) async throws -> Data {
        switch format {
        case .json:
            return try await exportToJSON(videos: videos)
        case .csv:
            return generateCSV(from: videos)
        case .pdf:
            return generatePDF(from: videos)
        }
    }

    func generateCSV(from videos: [VideoProgress]) -> Data {
        var csv = "Title,Platform,Current Position,Total Duration,Progress %,Last Updated,Completed\n"

        for video in videos {
            let row = [
                video.title.csvEscaped,
                video.streamingPlatform.displayName,
                video.formattedCurrentPosition,
                video.formattedTotalDuration,
                "\(Int(video.progressPercentage))%",
                video.lastUpdated.dateTimeString,
                video.isCompleted ? "Yes" : "No"
            ].joined(separator: ",")
            csv += row + "\n"
        }

        return Data(csv.utf8)
    }

    func generatePDF(from videos: [VideoProgress]) -> Data {
        let pdfData = NSMutableData()

        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        UIGraphicsBeginPDFPage()

        let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
        let headerFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let bodyFont = UIFont.systemFont(ofSize: 12)

        var y: CGFloat = 50

        "ResumePoint Export".draw(at: CGPoint(x: 50, y: y), withAttributes: [.font: titleFont])
        y += 40

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        "Exported: \(dateFormatter.string(from: Date()))".draw(
            at: CGPoint(x: 50, y: y),
            withAttributes: [.font: bodyFont, .foregroundColor: UIColor.secondaryLabel]
        )
        y += 30

        for video in videos {
            if y > 700 {
                UIGraphicsBeginPDFPage()
                y = 50
            }

            video.title.draw(at: CGPoint(x: 50, y: y), withAttributes: [.font: headerFont])
            y += 20

            let details = "\(video.streamingPlatform.displayName) • \(video.formattedCurrentPosition) / \(video.formattedTotalDuration) • \(Int(video.progressPercentage))%"
            details.draw(at: CGPoint(x: 50, y: y), withAttributes: [.font: bodyFont, .foregroundColor: UIColor.secondaryLabel])
            y += 25
        }

        UIGraphicsEndPDFContext()

        return pdfData as Data
    }

    private func exportToJSON(videos: [VideoProgress]) async throws -> Data {
        let exportData = videos.map { video -> [String: Any] in
            return [
                "id": video.id.uuidString,
                "title": video.title,
                "platform": video.platform,
                "currentPosition": video.currentPosition,
                "totalDuration": video.totalDuration,
                "progressPercentage": video.progressPercentage,
                "lastUpdated": video.lastUpdated.iso8601String,
                "isCompleted": video.isCompleted,
                "notes": video.notes ?? ""
            ]
        }
        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
}

extension String {
    var csvEscaped: String {
        if contains(",") || contains("\"") || contains("\n") {
            return "\"" + replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return self
    }
}
