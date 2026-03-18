import Foundation
import Supabase
import AuthenticationServices
import GoogleSignIn

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        let supabaseURL = URL(string: "https://edoumdymwuxndqtmcroz.supabase.co")!
        let supabaseKey = ""
        
        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        
        // Proactive Sanitization: Ensure legacy IDs are lowercased
        let prefs = UserDefaults.standard
        if let currentId = prefs.string(forKey: "currentUserId") {
            prefs.set(currentId.lowercased(), forKey: "currentUserId")
        }
        if let deviceId = prefs.string(forKey: "deviceId") {
            prefs.set(deviceId.lowercased(), forKey: "deviceId")
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, fullName: String) async throws -> User {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(fullName)]
        )
        
        return response.user
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws -> Session {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )
        
        return session
    }
    
    // MARK: - OAuth Providers
    func signInWithApple(idToken: String, nonce: String, fullName: String? = nil) async throws -> Session {
        let credentials = OpenIDConnectCredentials(
            provider: .apple,
            idToken: idToken,
            accessToken: nil,
            nonce: nonce
        )
        
        let session = try await client.auth.signInWithIdToken(credentials: credentials)
        
        // If we got a real fullName from Apple (only on first signup), update metadata
        if let fullName = fullName, !fullName.isEmpty {
            try? await updateUserMetadata(attributes: ["full_name": fullName])
        }
        
        return session
    }
    
    func signInWithGoogle(idToken: String, accessToken: String?, nonce: String? = nil) async throws -> Session {
        let credentials = OpenIDConnectCredentials(
            provider: .google,
            idToken: idToken,
            accessToken: accessToken,
            nonce: nonce
        )
        
        let session = try await client.auth.signInWithIdToken(credentials: credentials)
        return session
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    // MARK: - Get Current User
    func getCurrentUser() async throws -> User? {
        let session = try await client.auth.session
        return session.user
    }
    
    // MARK: - Check if User is Signed In
    var isUserSignedIn: Bool {
        get async {
            do {
                let session = try await client.auth.session
                return session.user != nil
            } catch {
                return false
            }
        }
    }
    
    // MARK: - Dedicated Current User ID Helper
    var currentUserID: String? {
        get async {
            do {
                let session = try await client.auth.session
                return session.user.id.uuidString.lowercased()
            } catch {
                return nil
            }
        }
    }
    
    // MARK: - Access Token
    var accessToken: String? {
        get async {
            do {
                let session = try await client.auth.session
                return session.accessToken
            } catch {
                return nil
            }
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    // MARK: - Update Password
    func updatePassword(newPassword: String) async throws {
        try await client.auth.update(
            user: UserAttributes(password: newPassword)
        )
    }
    
    // MARK: - Update User Metadata
    func updateUserMetadata(attributes: [String: Any]) async throws {
        // Convert [String: Any] to [String: AnyJSON]
        var data: [String: AnyJSON] = [:]
        for (key, value) in attributes {
            switch value {
            case let v as String:
                data[key] = .string(v)
            case let v as Int:
                data[key] = .integer(v)
            case let v as Double:
                data[key] = .double(v)
            case let v as Bool:
                data[key] = .bool(v)
            case let v as [String: Any]:
                // Recursively convert nested dictionaries if needed
                let nested = v.reduce(into: [String: AnyJSON]()) { acc, pair in
                    let (k, val) = pair
                    if let s = val as? String { acc[k] = .string(s) }
                    else if let i = val as? Int { acc[k] = .integer(i) }
                    else if let d = val as? Double { acc[k] = .double(d) }
                    else if let b = val as? Bool { acc[k] = .bool(b) }
                    else if let dict = val as? [String: Any] {
                        // Optional deeper recursion
                        var inner: [String: AnyJSON] = [:]
                        for (ik, iv) in dict {
                            if let s = iv as? String { inner[ik] = .string(s) }
                            else if let i = iv as? Int { inner[ik] = .integer(i) }
                            else if let d = iv as? Double { inner[ik] = .double(d) }
                            else if let b = iv as? Bool { inner[ik] = .bool(b) }
                        }
                        acc[k] = .object(inner)
                    } else if let arr = val as? [Any] {
                        let converted: [AnyJSON] = arr.compactMap { element in
                            if let s = element as? String { return .string(s) }
                            if let i = element as? Int { return .integer(i) }
                            if let d = element as? Double { return .double(d) }
                            if let b = element as? Bool { return .bool(b) }
                            return nil
                        }
                        acc[k] = .array(converted)
                    }
                }
                data[key] = .object(nested)
            case let v as [Any]:
                // Best-effort array conversion for simple types
                let arr: [AnyJSON] = v.compactMap { element in
                    if let s = element as? String { return .string(s) }
                    if let i = element as? Int { return .integer(i) }
                    if let d = element as? Double { return .double(d) }
                    if let b = element as? Bool { return .bool(b) }
                    return nil
                }
                data[key] = .array(arr)
            default:
                // Skip unsupported types
                continue
            }
        }
        
        try await client.auth.update(user: UserAttributes(data: data))
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case userNotFound
    case invalidCredentials
    case emailAlreadyExists
    case weakPassword
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidCredentials:
            return "Invalid email or password"
        case .emailAlreadyExists:
            return "Email already exists"
        case .weakPassword:
            return "Password is too weak"
        case .networkError:
            return "Network error. Please try again"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
