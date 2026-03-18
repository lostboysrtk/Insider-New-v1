//
//  Userprofiledb.swift
//  Insider
//
//  Created by Sarthak Sharma on 23/02/26.
//

// UserProfileDB.swift
// Database model and persistence manager for user profiles in Supabase

import Foundation
import UIKit

// MARK: - User Profile Database Model

/// Represents a complete user profile stored in Supabase `user_profiles` table.
/// The `id` column matches the Supabase Auth `auth.users.id` UUID so every
/// authenticated user maps 1-to-1 with a profile row.
struct UserProfileDB: Codable {

    // MARK: Identity
    let id: String?                     // auth.users UUID — set on first save
    let fullName: String
    let email: String
    let bio: String?
    let avatarURL: String?

    // MARK: Gamification
    let currentStreak: Int
    let recordStreak: Int
    let badgesCount: Int
    let badgePercentile: String?        // e.g. "Top 2%"

    // MARK: Personalised Feed
    let selectedDomains: [String]       // up to 2 home-tab domains, never "None"
    let followingTopics: [String]
    let blockedTopics: [String]
    let readingTimePreference: String   // e.g. "15 news"
    let professionalGoal: String

    // MARK: Account / Notification Settings
    let dailyDropAlertsEnabled: Bool
    let emailNewsletterEnabled: Bool
    let privacyProfilePublic: Bool

    // MARK: Metadata
    let createdAt: Date?
    let updatedAt: Date?

    // MARK: Memberwise init (private — used only by the convenience copying functions below)
    // Defining this here suppresses Swift's auto-synthesized memberwise init and
    // removes the "ambiguous use / invalid redeclaration" errors.
    init(
        id: String?, fullName: String, email: String, bio: String?,
        avatarURL: String?, currentStreak: Int, recordStreak: Int,
        badgesCount: Int, badgePercentile: String?,
        selectedDomains: [String], followingTopics: [String], blockedTopics: [String],
        readingTimePreference: String, professionalGoal: String,
        dailyDropAlertsEnabled: Bool, emailNewsletterEnabled: Bool,
        privacyProfilePublic: Bool, createdAt: Date?, updatedAt: Date?
    ) {
        self.id                      = id
        self.fullName                = fullName
        self.email                   = email
        self.bio                     = bio
        self.avatarURL               = avatarURL
        self.currentStreak           = currentStreak
        self.recordStreak            = recordStreak
        self.badgesCount             = badgesCount
        self.badgePercentile         = badgePercentile
        self.selectedDomains         = selectedDomains
        self.followingTopics         = followingTopics
        self.blockedTopics           = blockedTopics
        self.readingTimePreference   = readingTimePreference
        self.professionalGoal        = professionalGoal
        self.dailyDropAlertsEnabled  = dailyDropAlertsEnabled
        self.emailNewsletterEnabled  = emailNewsletterEnabled
        self.privacyProfilePublic    = privacyProfilePublic
        self.createdAt               = createdAt
        self.updatedAt               = updatedAt
    }

    // MARK: CodingKeys — map Swift camelCase → Postgres snake_case
    enum CodingKeys: String, CodingKey {
        case id
        case fullName               = "full_name"
        case email
        case bio
        case avatarURL              = "avatar_url"
        case currentStreak          = "current_streak"
        case recordStreak           = "record_streak"
        case badgesCount            = "badges_count"
        case badgePercentile        = "badge_percentile"
        case selectedDomains        = "selected_domains"
        case followingTopics        = "following_topics"
        case blockedTopics          = "blocked_topics"
        case readingTimePreference  = "reading_time_preference"
        case professionalGoal       = "professional_goal"
        case dailyDropAlertsEnabled = "daily_drop_alerts_enabled"
        case emailNewsletterEnabled = "email_newsletter_enabled"
        case privacyProfilePublic   = "privacy_profile_public"
        case createdAt              = "created_at"
        case updatedAt              = "updated_at"
    }
}

// MARK: - Convenience Initialisers

extension UserProfileDB {

    /// Build a brand-new profile on first registration.
    /// Call this right after Supabase Auth sign-up succeeds.
    init(userId: String, fullName: String, email: String) {
        self.id                      = userId
        self.fullName                = fullName
        self.email                   = email
        self.bio                     = nil
        self.avatarURL               = nil
        self.currentStreak           = 0
        self.recordStreak            = 0
        self.badgesCount             = 0
        self.badgePercentile         = nil
        self.selectedDomains         = []
        self.followingTopics         = []
        self.blockedTopics           = []
        self.readingTimePreference   = "15 news"
        self.professionalGoal        = "General Knowledge"
        self.dailyDropAlertsEnabled  = true
        self.emailNewsletterEnabled  = true
        self.privacyProfilePublic    = true
        self.createdAt               = nil
        self.updatedAt               = nil
    }

    /// Return a copy with only the personal-detail fields changed.
    func updatingPersonalDetails(fullName: String, bio: String?, avatarURL: String? = nil) -> UserProfileDB {
        UserProfileDB(
            id: id,
            fullName: fullName,
            email: email,
            bio: bio.flatMap { $0.isEmpty ? nil : $0 },
            avatarURL: avatarURL ?? self.avatarURL,
            currentStreak: currentStreak,
            recordStreak: recordStreak,
            badgesCount: badgesCount,
            badgePercentile: badgePercentile,
            selectedDomains: selectedDomains,
            followingTopics: followingTopics,
            blockedTopics: blockedTopics,
            readingTimePreference: readingTimePreference,
            professionalGoal: professionalGoal,
            dailyDropAlertsEnabled: dailyDropAlertsEnabled,
            emailNewsletterEnabled: emailNewsletterEnabled,
            privacyProfilePublic: privacyProfilePublic,
            createdAt: createdAt,
            updatedAt: nil
        )
    }

    /// Return a copy with only the feed-preference fields changed.
    func updatingFeedPreferences(
        selectedDomains: [String],
        followingTopics: [String],
        blockedTopics: [String],
        readingTime: String,
        goal: String
    ) -> UserProfileDB {
        UserProfileDB(
            id: id,
            fullName: fullName,
            email: email,
            bio: bio,
            avatarURL: avatarURL,
            currentStreak: currentStreak,
            recordStreak: recordStreak,
            badgesCount: badgesCount,
            badgePercentile: badgePercentile,
            selectedDomains: selectedDomains,
            followingTopics: followingTopics,
            blockedTopics: blockedTopics,
            readingTimePreference: readingTime,
            professionalGoal: goal,
            dailyDropAlertsEnabled: dailyDropAlertsEnabled,
            emailNewsletterEnabled: emailNewsletterEnabled,
            privacyProfilePublic: privacyProfilePublic,
            createdAt: createdAt,
            updatedAt: nil
        )
    }

    /// Return a copy with only the account-settings fields changed.
    func updatingAccountSettings(
        dailyDropAlerts: Bool,
        emailNewsletter: Bool,
        profilePublic: Bool
    ) -> UserProfileDB {
        UserProfileDB(
            id: id,
            fullName: fullName,
            email: email,
            bio: bio,
            avatarURL: avatarURL,
            currentStreak: currentStreak,
            recordStreak: recordStreak,
            badgesCount: badgesCount,
            badgePercentile: badgePercentile,
            selectedDomains: selectedDomains,
            followingTopics: followingTopics,
            blockedTopics: blockedTopics,
            readingTimePreference: readingTimePreference,
            professionalGoal: professionalGoal,
            dailyDropAlertsEnabled: dailyDropAlerts,
            emailNewsletterEnabled: emailNewsletter,
            privacyProfilePublic: profilePublic,
            createdAt: createdAt,
            updatedAt: nil
        )
    }

}

// MARK: - Partial Update Payloads
// These small Codable structs let us PATCH only the columns we care about,
// avoiding accidental overwrites of streak/badge data, etc.

struct PersonalDetailsUpdate: Encodable {
    let fullName: String
    let bio: String?
    let avatarURL: String?
    enum CodingKeys: String, CodingKey {
        case fullName  = "full_name"
        case bio
        case avatarURL = "avatar_url"
    }
}

struct FeedPreferencesUpdate: Encodable {
    let selectedDomains: [String]
    let followingTopics: [String]
    let blockedTopics: [String]
    let readingTimePreference: String
    let professionalGoal: String
    enum CodingKeys: String, CodingKey {
        case selectedDomains       = "selected_domains"
        case followingTopics       = "following_topics"
        case blockedTopics         = "blocked_topics"
        case readingTimePreference = "reading_time_preference"
        case professionalGoal      = "professional_goal"
    }
}

struct AccountSettingsUpdate: Encodable {
    let dailyDropAlertsEnabled: Bool
    let emailNewsletterEnabled: Bool
    let privacyProfilePublic: Bool
    enum CodingKeys: String, CodingKey {
        case dailyDropAlertsEnabled = "daily_drop_alerts_enabled"
        case emailNewsletterEnabled = "email_newsletter_enabled"
        case privacyProfilePublic   = "privacy_profile_public"
    }
}

struct GamificationUpdate: Encodable {
    let currentStreak: Int
    let recordStreak: Int
    let badgesCount: Int
    let badgePercentile: String?
    enum CodingKeys: String, CodingKey {
        case currentStreak   = "current_streak"
        case recordStreak    = "record_streak"
        case badgesCount     = "badges_count"
        case badgePercentile = "badge_percentile"
    }
}

// MARK: - UserProfilePersistenceManager

/// Single point of truth for reading and writing user profiles.
/// All methods are asynchronous and call back on the calling queue (not main).
/// Wrap UI updates in DispatchQueue.main.async / MainActor as needed.
final class UserProfilePersistenceManager {

    static let shared = UserProfilePersistenceManager()
    private init() {}

    private let endpoint = "user_profiles"

    // MARK: - Create (on Registration)

    /// Creates a new profile row in Supabase.
    /// Call this immediately after a successful Auth sign-up.
    func createProfile(
        _ profile: UserProfileDB,
        completion: @escaping (Result<UserProfileDB, SupabaseError>) -> Void
    ) {
        SupabaseService.shared.post(
            endpoint: endpoint,
            body: profile,
            completion: completion
        )
    }

    // MARK: - Fetch

    /// Fetches the profile for the given Auth user ID.
    func fetchProfile(
        userId: String,
        completion: @escaping (Result<UserProfileDB?, SupabaseError>) -> Void
    ) {
        let params = ["id": "eq.\(userId)", "limit": "1"]
        SupabaseService.shared.get(
            endpoint: endpoint,
            queryParams: params
        ) { (result: Result<[UserProfileDB], SupabaseError>) in
            switch result {
            case .success(let profiles):
                completion(.success(profiles.first))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Partial Updates

    /// Update only personal details (name, bio, avatar).
    func updatePersonalDetails(
        userId: String,
        fullName: String,
        bio: String?,
        avatarURL: String? = nil,
        completion: @escaping (Result<UserProfileDB, SupabaseError>) -> Void
    ) {
        let payload = PersonalDetailsUpdate(fullName: fullName, bio: bio, avatarURL: avatarURL)
        patchProfile(userId: userId, body: payload, completion: completion)
    }

    /// Update only personalised-feed preferences.
    func updateFeedPreferences(
        userId: String,
        selectedDomains: [String],
        followingTopics: [String],
        blockedTopics: [String],
        readingTime: String,
        goal: String,
        completion: @escaping (Result<UserProfileDB, SupabaseError>) -> Void
    ) {
        let payload = FeedPreferencesUpdate(
            selectedDomains: selectedDomains,
            followingTopics: followingTopics,
            blockedTopics: blockedTopics,
            readingTimePreference: readingTime,
            professionalGoal: goal
        )
        patchProfile(userId: userId, body: payload, completion: completion)
    }

    /// Update only account / notification settings.
    func updateAccountSettings(
        userId: String,
        dailyDropAlerts: Bool,
        emailNewsletter: Bool,
        profilePublic: Bool,
        completion: @escaping (Result<UserProfileDB, SupabaseError>) -> Void
    ) {
        let payload = AccountSettingsUpdate(
            dailyDropAlertsEnabled: dailyDropAlerts,
            emailNewsletterEnabled: emailNewsletter,
            privacyProfilePublic: profilePublic
        )
        patchProfile(userId: userId, body: payload, completion: completion)
    }

    /// Update streak and badge gamification values.
    func updateGamification(
        userId: String,
        currentStreak: Int,
        recordStreak: Int,
        badgesCount: Int,
        badgePercentile: String?,
        completion: @escaping (Result<UserProfileDB, SupabaseError>) -> Void
    ) {
        let payload = GamificationUpdate(
            currentStreak: currentStreak,
            recordStreak: recordStreak,
            badgesCount: badgesCount,
            badgePercentile: badgePercentile
        )
        patchProfile(userId: userId, body: payload, completion: completion)
    }

    // MARK: - Delete

    func deleteProfile(
        userId: String,
        completion: @escaping (Result<[UserProfileDB], SupabaseError>) -> Void
    ) {
        SupabaseService.shared.delete(
            endpoint: endpoint,
            queryParams: ["id": "eq.\(userId)"],
            completion: completion
        )
    }

    // MARK: - Upsert Helper
    // If you want a "create if not exists, else update" flow (e.g., after social login)
    // use this instead of createProfile.

    func upsertProfile(
        _ profile: UserProfileDB,
        completion: @escaping (Result<UserProfileDB, SupabaseError>) -> Void
    ) {
        // Supabase upsert: POST with Prefer: resolution=merge-duplicates
        // We reuse the generic post but add the Prefer header via a subclass approach.
        // For simplicity we do a fetch-then-create/update here.
        guard let userId = profile.id else {
            completion(.failure(.serverError("Profile has no id")))
            return
        }
        fetchProfile(userId: userId) { [weak self] result in
            switch result {
            case .success(let existing):
                if existing != nil {
                    // Already exists — update personal details to avoid stomping gamification
                    self?.updatePersonalDetails(
                        userId: userId,
                        fullName: profile.fullName,
                        bio: profile.bio,
                        avatarURL: profile.avatarURL,
                        completion: completion
                    )
                } else {
                    // New user — create full row
                    self?.createProfile(profile, completion: completion)
                }
            case .failure:
                // Assume row doesn't exist and try to create
                self?.createProfile(profile, completion: completion)
            }
        }
    }

    // MARK: - Private Helpers

    private func patchProfile<T: Encodable>(
        userId: String,
        body: T,
        completion: @escaping (Result<UserProfileDB, SupabaseError>) -> Void
    ) {
        SupabaseService.shared.update(
            endpoint: endpoint,
            body: body,
            queryParams: ["id": "eq.\(userId)"]
        ) { (result: Result<[UserProfileDB], SupabaseError>) in
            switch result {
            case .success(let profiles):
                if let first = profiles.first {
                    completion(.success(first))
                } else {
                    completion(.failure(.notFound))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
