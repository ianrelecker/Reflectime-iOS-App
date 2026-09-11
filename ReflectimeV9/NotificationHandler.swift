import Foundation
import UserNotifications

@MainActor
final class ReflectionNotifier {
    static let shared = ReflectionNotifier()
    static let reminderIdentifier = "reflectime.daily.reminder"

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            UserDefaults.standard.set(granted, forKey: "authorized")
        }
    }

    func applySchedule(date: Date, enabled: Bool) {
        UserDefaults.standard.set(date, forKey: "Date")
        UserDefaults.standard.set(enabled, forKey: "sendNot")

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])
        center.removeAllPendingNotificationRequests()

        guard enabled else { return }

        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "Reflectime"
        content.body = Self.reminderBody()
        content.sound = .default
        content.badge = 1
        content.userInfo = ["deepLink": "reflectime://new"]

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.reminderIdentifier,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    static func storedReminderDate() -> Date {
        (UserDefaults.standard.object(forKey: "Date") as? Date) ?? Date()
    }

    static func reminderBody() -> String {
        let prompt = ReflectionDefaults.prompts.randomElement() ?? "Now is the time to reflect."
        let firstLine = prompt.split(whereSeparator: \.isNewline).first.map(String.init) ?? prompt
        if firstLine.count > 120 {
            return "Now is the time to reflect."
        }
        return firstLine
    }
}
