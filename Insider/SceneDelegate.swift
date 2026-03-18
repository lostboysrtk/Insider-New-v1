import UIKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create the window
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        setupGlobalAppearance(for: window)
        
        // Determine the initial view controller based on auth state
        Task {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if await SupabaseManager.shared.isUserSignedIn {
                // User is signed in -> Go straight to Main Tab Bar
                guard let mainTabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarControllerID") as? UITabBarController else {
                    return
                }
                await MainActor.run {
                    window.rootViewController = mainTabBarVC
                    window.makeKeyAndVisible()
                }
            } else {
                // User is not signed in -> Go to LaunchingViewController
                await MainActor.run {
                    let launchingVC = LaunchingViewController()
                    window.rootViewController = launchingVC
                    window.makeKeyAndVisible()
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {
        StreakManager.shared.checkStreakOnLaunch()
    }
    func sceneDidEnterBackground(_ scene: UIScene) {}
    
    // MARK: - Google Sign-In URL Handler
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: - Global Appearance Setup
    private func setupGlobalAppearance(for window: UIWindow) {
        // 1. Global Window Tint (affects default buttons, back carats, interactable elements)
        window.tintColor = AppColor.brand
        
        // 2. Tab Bar Appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = AppColor.background
        appearance.shadowColor = AppColor.Surface.cardBorder
        
        // Unselected tabs
        appearance.stackedLayoutAppearance.normal.iconColor = AppColor.iconSubdued
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: AppColor.Text.tertiary
        ]
        
        // Selected tabs
        appearance.stackedLayoutAppearance.selected.iconColor = AppColor.brand
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: AppColor.brand
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        UITabBar.appearance().tintColor = AppColor.brand
    }
}
