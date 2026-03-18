// StreakManager.swift
// Insider
//
// Manages daily reading streaks. A "day" boundary is 5:00 AM local time.
// When the user scrolls to the end of the "For You" feed, call markTodayAsRead().
// Call checkStreakOnLaunch() every time the app enters the foreground.

import Foundation
internal import Auth

final class StreakManager {

    static let shared = StreakManager()
    private init() {}

    // MARK: - UserDefaults Keys

    private let lastReadDateKey   = "StreakLastReadDate"
    private let currentStreakKey  = "StreakCurrentCount"
    private let recordStreakKey   = "StreakRecordCount"

    // MARK: - 5 AM Day Boundary

    /// Returns the "streak day" for a given date.
    /// Everything before 5 AM counts as the previous calendar day.
    private func streakDay(for date: Date = Date()) -> DateComponents {
        var cal = Calendar.current
        cal.timeZone = .current
        let comps = cal.dateComponents([.year, .month, .day, .hour], from: date)
        var day = cal.dateComponents([.year, .month, .day], from: date)
        if let hour = comps.hour, hour < 5 {
            // Before 5 AM — treat as previous day
            if let shifted = cal.date(byAdding: .day, value: -1, to: date) {
                day = cal.dateComponents([.year, .month, .day], from: shifted)
            }
        }
        return day
    }

    /// Converts DateComponents to a comparable Date at midnight.
    private func dateFromComponents(_ dc: DateComponents) -> Date? {
        Calendar.current.date(from: dc)
    }

    // MARK: - Public API

    /// Call when user scrolls to the end of "For You" feed.
    func markTodayAsRead() {
        let today = streakDay()
        let prefs = UserDefaults.standard

        // Already marked today?
        if let lastData = prefs.data(forKey: lastReadDateKey),
           let lastDC = try? JSONDecoder().decode(CodableDateComponents.self, from: lastData),
           lastDC.toDateComponents() == today {
            return // Already counted for this streak day
        }

        var currentStreak = prefs.integer(forKey: currentStreakKey)
        var recordStreak  = prefs.integer(forKey: recordStreakKey)

        // Check if yesterday was the last read day (consecutive)
        if let lastData = prefs.data(forKey: lastReadDateKey),
           let lastDC = try? JSONDecoder().decode(CodableDateComponents.self, from: lastData),
           let lastDate = dateFromComponents(lastDC.toDateComponents()),
           let todayDate = dateFromComponents(today) {
            let diff = Calendar.current.dateComponents([.day], from: lastDate, to: todayDate).day ?? 0
            if diff == 1 {
                // Consecutive day — increment
                currentStreak += 1
            } else {
                // Gap — start new streak
                currentStreak = 1
            }
        } else {
            // First time ever
            currentStreak = 1
        }

        if currentStreak > recordStreak {
            recordStreak = currentStreak
        }

        // Persist locally
        prefs.set(currentStreak, forKey: currentStreakKey)
        prefs.set(recordStreak, forKey: recordStreakKey)
        if let encoded = try? JSONEncoder().encode(CodableDateComponents(from: today)) {
            prefs.set(encoded, forKey: lastReadDateKey)
        }

        // Sync to Supabase
        syncToDatabase(currentStreak: currentStreak, recordStreak: recordStreak)

        // Post notification so Profile screen can update live
        NotificationCenter.default.post(name: .streakDidUpdate, object: nil)
    }

    /// Call in sceneWillEnterForeground to detect missed days.
    func checkStreakOnLaunch() {
        let prefs = UserDefaults.standard
        let today = streakDay()

        guard let lastData = prefs.data(forKey: lastReadDateKey),
              let lastDC = try? JSONDecoder().decode(CodableDateComponents.self, from: lastData),
              let lastDate = dateFromComponents(lastDC.toDateComponents()),
              let todayDate = dateFromComponents(today) else {
            return // No streak data yet, nothing to reset
        }

        let diff = Calendar.current.dateComponents([.day], from: lastDate, to: todayDate).day ?? 0

        // If more than 1 day has passed since the last read, reset the streak
        if diff > 1 {
            prefs.set(0, forKey: currentStreakKey)
            // Record stays
            syncToDatabase(currentStreak: 0, recordStreak: prefs.integer(forKey: recordStreakKey))
            NotificationCenter.default.post(name: .streakDidUpdate, object: nil)
        }
    }

    /// Hydrate local streak cache from a fetched profile (e.g. on login).
    func hydrateFromProfile(_ profile: UserProfileDB) {
        let prefs = UserDefaults.standard
        prefs.set(profile.currentStreak, forKey: currentStreakKey)
        prefs.set(profile.recordStreak, forKey: recordStreakKey)
    }

    // MARK: - Read-Only Accessors

    var currentStreak: Int {
        UserDefaults.standard.integer(forKey: currentStreakKey)
    }

    var recordStreak: Int {
        UserDefaults.standard.integer(forKey: recordStreakKey)
    }

    // MARK: - Database Sync

    private func syncToDatabase(currentStreak: Int, recordStreak: Int) {
        Task {
            guard let user = try? await SupabaseManager.shared.getCurrentUser() else { return }
            let userId = user.id.uuidString

            // Fetch current badges to avoid overwriting them
            let badges = UserDefaults.standard.integer(forKey: "BadgesCount")
            let percentile = UserDefaults.standard.string(forKey: "BadgePercentile")

            UserProfilePersistenceManager.shared.updateGamification(
                userId: userId,
                currentStreak: currentStreak,
                recordStreak: recordStreak,
                badgesCount: badges,
                badgePercentile: percentile
            ) { result in
                switch result {
                case .success:
                    print("✅ [Streak] Synced to database: streak=\(currentStreak), record=\(recordStreak)")
                case .failure(let error):
                    print("⚠️ [Streak] DB sync failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let streakDidUpdate = Notification.Name("StreakDidUpdate")
}

// MARK: - Codable DateComponents Helper

/// A Codable wrapper so we can persist DateComponents (year/month/day) in UserDefaults.
private struct CodableDateComponents: Codable {
    let year: Int
    let month: Int
    let day: Int

    init(from dc: DateComponents) {
        self.year  = dc.year  ?? 1970
        self.month = dc.month ?? 1
        self.day   = dc.day   ?? 1
    }

    func toDateComponents() -> DateComponents {
        DateComponents(year: year, month: month, day: day)
    }
}
