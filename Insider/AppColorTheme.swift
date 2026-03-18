//
//  AppColorTheme.swift
//  Insider
//
//  ═══════════════════════════════════════════════════════════════════════════
//  THE SINGLE SOURCE OF TRUTH for every colour in the app.
//
//  This file replaces:
//    • UIColor+Brand.swift  (delete that file once this is added)
//    • Every hardcoded UIColor(red:green:blue:) across all view controllers
//
//  HOW TO USE — UIKit
//  ──────────────────
//    view.backgroundColor  = AppColor.background
//    label.textColor       = AppColor.Text.primary
//    button.backgroundColor = AppColor.Brand.button
//    btn.tintColor         = AppColor.brand          // shorthand
//
//  HOW TO USE — SwiftUI
//  ─────────────────────
//    .foregroundColor(AppColor.SwiftUI.brand)
//    .background(AppColor.SwiftUI.background)
//    Button(...).buttonStyle(AppColor.SwiftUI.PrimaryButtonStyle())
//
//  QUICK REFERENCE — most-used tokens
//  ────────────────────────────────────
//    AppColor.brand                   → primary purple, filters / badges / tints
//    AppColor.Brand.button            → auth screen CTA buttons
//    AppColor.Brand.mid               → preference cards / toolkit icons
//    AppColor.background              → main screen bg
//    AppColor.Text.primary            → near-black headings
//    AppColor.Text.secondary          → sub-headings
//    AppColor.Text.tertiary           → captions / placeholders
//    AppColor.Text.adaptive           → light-dark safe body text (= .label)
//    AppColor.Surface.cardBorder      → default card border
//    AppColor.Surface.shadow          → box shadow colour
//  ═══════════════════════════════════════════════════════════════════════════

import UIKit
import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - AppColor  (UIKit)
// ─────────────────────────────────────────────────────────────────────────────

enum AppColor {

    // ── Brand ─────────────────────────────────────────────────────────────────

    /// Primary brand purple.
    /// Replaces: UIColor(red:0.40,g:0.52,b:0.89), .systemBlue, .systemIndigo
    /// Used in: filter chips, category badges, date labels, loading spinners,
    ///          play-pause tint, transcript toggle, "View All" chevron.
    static let brand = UIColor(red: 0.40, green: 0.52, blue: 0.89, alpha: 1.0)

    enum Brand {
        /// Slightly deeper blue – auth-screen CTAs, icon tints, link text.
        /// UIColor(red:0.40, green:0.55, blue:0.85)
        static let button   = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1.0)

        /// Mid-weight brand – preference card highlights, toolkit icon tints.
        /// UIColor(red:0.35, green:0.50, blue:0.75)
        static let mid      = UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 1.0)

        /// Deep brand – onboarding slide 3 background.
        /// UIColor(red:0.25, green:0.40, blue:0.65)
        static let deep     = UIColor(red: 0.25, green: 0.40, blue: 0.65, alpha: 1.0)

        /// Darkest brand – onboarding slide 4 background.
        /// UIColor(red:0.15, green:0.30, blue:0.55)
        static let darkest  = UIColor(red: 0.15, green: 0.30, blue: 0.55, alpha: 1.0)

        /// Shadow colour for CTA buttons (40% opacity).
        static let shadow   = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 0.40)

        /// Faint tint for bubble overlays behind auth forms.
        static let bubble1  = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 0.08)
        static let bubble2  = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 0.06)
        static let bubble3  = UIColor(red: 0.20, green: 0.35, blue: 0.65, alpha: 0.05)
    }

    // ── Backgrounds ───────────────────────────────────────────────────────────

    /// Primary screen background (light/dark adaptive).
    static let background           = UIColor.systemBackground

    /// Card / input container background (light/dark adaptive).
    static let backgroundSecondary  = UIColor.secondarySystemBackground

    /// Frosted-glass card used in auth forms.
    static let backgroundGlass      = UIColor.white.withAlphaComponent(0.75)

    /// Social-login button fill.
    static let backgroundSocialBtn  = UIColor.white.withAlphaComponent(0.85)

    /// Image / thumbnail placeholder tile.
    static let backgroundPlaceholder = UIColor.systemGray6

    // ── Animated gradient – Sign In / Sign Up background ─────────────────────

    enum Gradient {
        static let top    = UIColor(red: 0.93, green: 0.95, blue: 0.98, alpha: 1)
        static let middle = UIColor(red: 0.88, green: 0.92, blue: 0.97, alpha: 1)
        static let bottom = UIColor(red: 0.85, green: 0.90, blue: 0.96, alpha: 1)

        /// Preference screen two-stop gradient.
        static let prefTop    = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
        static let prefBottom = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1)
    }

    // ── Text ─────────────────────────────────────────────────────────────────

    enum Text {
        /// Bold headings – near-black.
        /// UIColor(red:0.10, green:0.10, blue:0.12)
        static let primary      = UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)

        /// Sub-headings / supporting copy.
        /// UIColor(red:0.25, green:0.25, blue:0.28)
        static let secondary    = UIColor(red: 0.25, green: 0.25, blue: 0.28, alpha: 1)

        /// Captions, placeholders, helper text, "or continue with".
        /// UIColor(red:0.40, green:0.40, blue:0.45)
        static let tertiary     = UIColor(red: 0.40, green: 0.40, blue: 0.45, alpha: 1)

        /// Light-dark adaptive body text (maps to UIColor.label).
        static let adaptive     = UIColor.label

        /// Light-dark adaptive supporting text (maps to UIColor.secondaryLabel).
        static let adaptiveSub  = UIColor.secondaryLabel

        /// Coloured link / CTA text – auth links, tag labels.
        static let link         = AppColor.Brand.button

        // Transcript reading states
        static let transcriptRead    = UIColor.label
        static let transcriptActive  = UIColor.label.withAlphaComponent(0.70)
        static let transcriptUnread  = UIColor.label.withAlphaComponent(0.30)
        static let transcriptDim     = UIColor.label.withAlphaComponent(0.25)
    }

    // ── Surface & Borders ─────────────────────────────────────────────────────

    enum Surface {
        /// Frosted-glass card rim.
        static let glassBorder      = UIColor.white.withAlphaComponent(0.90)

        /// Default input / card border.
        /// UIColor(red:0.88, green:0.90, blue:0.93)
        static let cardBorder       = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1)

        /// Social-login button border.
        /// UIColor(red:0.85, green:0.87, blue:0.90)
        static let socialBorder     = UIColor(red: 0.85, green: 0.87, blue: 0.90, alpha: 1)

        /// Selected preference-card border.
        static let selectedBorder   = AppColor.Brand.mid

        /// Selected preference-card fill tint (12% opacity).
        static let selectedFill     = UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 0.12)

        /// Cell / section separator.
        static let separator        = UIColor.separator.withAlphaComponent(0.30)
        static let separatorStrong  = UIColor.separator.withAlphaComponent(0.40)

        /// Horizontal rule ("or continue with" divider lines).
        static let divider          = UIColor(red: 0.70, green: 0.70, blue: 0.75, alpha: 1)

        /// Default box-shadow colour – deep brand at very low opacity.
        static let shadow           = UIColor(red: 0.12, green: 0.25, blue: 0.55, alpha: 0.08)

        /// Selected card shadow.
        static let shadowSelected   = UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 0.20)
    }

    // ── Miscellaneous controls ────────────────────────────────────────────────

    /// Dismiss / close icon colour (subdued grey).
    static let iconSubdued      = UIColor.systemGray2

    /// Image-placeholder icon tint.
    static let iconPlaceholder  = UIColor.systemGray4

    /// Volume slider inactive track.
    static let sliderTrack      = UIColor.systemGray3

    /// Playback control icon colour (light/dark adaptive).
    static let controlIcon      = UIColor.label

    /// Inactive pagination dot (preference / onboarding screens).
    static let dotInactive      = UIColor(red: 0.85, green: 0.87, blue: 0.90, alpha: 1)

    // ── Status ────────────────────────────────────────────────────────────────

    enum Status {
        static let success  = UIColor.systemGreen
        static let warning  = UIColor(red: 0.96, green: 0.62, blue: 0.04, alpha: 1)  // #F59E0B
        static let error    = UIColor(red: 0.94, green: 0.27, blue: 0.27, alpha: 1)  // #EF4444
    }

    // ── Onboarding (GetStartedViewController) ─────────────────────────────────

    enum Onboarding {
        static let slide1       = UIColor(red: 0.85, green: 0.90, blue: 0.98, alpha: 1)  // light blue-white
        static let slide2       = AppColor.Brand.mid      // 0.35,0.50,0.75
        static let slide3       = AppColor.Brand.deep     // 0.25,0.40,0.65
        static let slide4       = AppColor.Brand.darkest  // 0.15,0.30,0.55
        static let ctaButton    = AppColor.Brand.button   // "GET STARTED"
        static let navOverlay   = UIColor.black.withAlphaComponent(0.25)   // SWIPE/BACK btns
        static let progressTrack = UIColor.black.withAlphaComponent(0.10)
    }

    // ── Dev Toolkit pill / icon accent colours (NewAudioData.swift) ──────────

    enum Toolkit {
        static let swiftUI      = UIColor.systemOrange
        static let pythonDS     = AppColor.brand                               // brand purple
        static let nodeJS       = UIColor.systemGreen
        static let docker       = UIColor.systemCyan
        static let aws          = UIColor(red: 1.00, green: 0.60, blue: 0.00, alpha: 1)  // AWS orange
        static let kubernetes   = UIColor(red: 0.20, green: 0.40, blue: 0.80, alpha: 1)  // K8s blue
    }

    // ── Domain selection chips (PreferenceSelection2ViewController) ───────────
    // These map to .systemXxx colours used in the domain grid

    enum Domain {
        static let python   = UIColor.systemBlue
        static let swift    = UIColor.systemOrange
        static let devOps   = UIColor.systemIndigo
        static let data     = UIColor.systemPurple
        static let security = UIColor.systemRed
        static let webDev   = UIColor.systemGreen
        static let android  = UIColor.systemMint
        static let go       = UIColor.systemCyan
        static let rust     = UIColor.systemBrown
        static let nodeJS   = UIColor.systemGreen
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - UIColor convenience shorthands
// Keeps `.brand`, `.brandButton`, `.brandMid` dot-syntax working everywhere.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - SwiftUI mirror  (used in AppTheme-based SwiftUI views)
// ─────────────────────────────────────────────────────────────────────────────

extension AppColor {
    enum SwiftUI {

        // Brand
        static let brand        = Color(uiColor: AppColor.brand)
        static let brandButton  = Color(uiColor: AppColor.Brand.button)
        static let brandMid     = Color(uiColor: AppColor.Brand.mid)
        static let brandDeep    = Color(uiColor: AppColor.Brand.deep)
        static let brandDarkest = Color(uiColor: AppColor.Brand.darkest)

        // Backgrounds
        static let background           = Color(uiColor: AppColor.background)
        static let backgroundSecondary  = Color(uiColor: AppColor.backgroundSecondary)
        static let backgroundGlass      = Color.white.opacity(0.75)
        static let backgroundPlaceholder = Color(uiColor: AppColor.backgroundPlaceholder)

        // Gradient
        static let gradientTop    = Color(uiColor: AppColor.Gradient.top)
        static let gradientMiddle = Color(uiColor: AppColor.Gradient.middle)
        static let gradientBottom = Color(uiColor: AppColor.Gradient.bottom)

        // Text
        static let textPrimary   = Color(uiColor: AppColor.Text.primary)
        static let textSecondary = Color(uiColor: AppColor.Text.secondary)
        static let textTertiary  = Color(uiColor: AppColor.Text.tertiary)
        static let textAdaptive  = Color(uiColor: AppColor.Text.adaptive)
        static let textLink      = Color(uiColor: AppColor.Text.link)

        // Status
        static let success = Color(uiColor: AppColor.Status.success)
        static let warning = Color(uiColor: AppColor.Status.warning)
        static let error   = Color(uiColor: AppColor.Status.error)

        // ── Button styles ─────────────────────────────────────────────────────

        struct PrimaryButtonStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [brandButton, brandMid],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(uiColor: AppColor.Brand.shadow), radius: 6, x: 0, y: 3)
                    .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            }
        }

        struct SecondaryButtonStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(brand)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(brand.opacity(0.10))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(brand.opacity(0.30), lineWidth: 1)
                    )
                    .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            }
        }

        // ── Background view ───────────────────────────────────────────────────

        struct AppBackground: View {
            var body: some View {
                LinearGradient(
                    colors: [gradientTop, Color.white, gradientBottom.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
        }
    }
}
