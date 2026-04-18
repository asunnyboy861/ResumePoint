import Foundation

extension Double {
    func formattedTime() -> String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    var progressColorValue: Double {
        guard self > 0 else { return 0 }
        return min(self / 100, 1)
    }
}
