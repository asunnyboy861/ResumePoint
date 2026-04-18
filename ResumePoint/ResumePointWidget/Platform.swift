import Foundation

enum StreamingPlatform: String, CaseIterable, Identifiable, Codable {
    case netflix = "netflix"
    case disneyplus = "disneyplus"
    case hbomax = "hbomax"
    case primevideo = "primevideo"
    case appletvplus = "appletvplus"
    case hulu = "hulu"
    case youtube = "youtube"
    case paramount = "paramount"
    case peacock = "peacock"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .netflix: return "Netflix"
        case .disneyplus: return "Disney+"
        case .hbomax: return "Max"
        case .primevideo: return "Prime Video"
        case .appletvplus: return "Apple TV+"
        case .hulu: return "Hulu"
        case .youtube: return "YouTube"
        case .paramount: return "Paramount+"
        case .peacock: return "Peacock"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .netflix: return "n.square.fill"
        case .disneyplus: return "d.square.fill"
        case .hbomax: return "h.square.fill"
        case .primevideo: return "p.square.fill"
        case .appletvplus: return "appletv.fill"
        case .hulu: return "h.square.fill"
        case .youtube: return "play.rectangle.fill"
        case .paramount: return "p.square.fill"
        case .peacock: return "p.square.fill"
        case .other: return "play.rectangle"
        }
    }

    var accentColor: String {
        switch self {
        case .netflix: return "E50914"
        case .disneyplus: return "0063E5"
        case .hbomax: return "B01EE5"
        case .primevideo: return "00A8E1"
        case .appletvplus: return "000000"
        case .hulu: return "1CE783"
        case .youtube: return "FF0000"
        case .paramount: return "0064FF"
        case .peacock: return "000000"
        case .other: return "8E8E93"
        }
    }

    static func fromDisplayName(_ name: String) -> StreamingPlatform {
        StreamingPlatform.allCases.first { $0.displayName.lowercased() == name.lowercased() } ?? .other
    }
}
