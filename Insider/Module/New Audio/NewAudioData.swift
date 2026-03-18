//
//  NewAudioData.swift
//  Insider
//
//  Created by Sarthak Sharma on 22/12/25.
//

import UIKit

extension DateFormatter {
    static func with(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
}

// MARK: - Data Models
struct TopChoiceItem {
    let title: String
    let date: String
    let summary: String
    let category: String
    let imageUrl: String?
    let publishedDate: Date?
}

struct BreakingNewsItem {
    let category: String
    let headline: String
    let source: String
    let imageUrl: String?
}

struct DevToolkit {
    let name: String
    let icon: String
    let color: UIColor
    let keywords: [String]
}

// MARK: - Main Data Store
class AudioDataStore {
    static let shared = AudioDataStore()
    private init() {}
    
    // MARK: - Breaking News
    let breakingNews: [BreakingNewsItem] = [
        BreakingNewsItem(
            category: "Artificial Intelligence",
            headline: "OpenAI launches GPT-5 with multimodal reasoning",
            source: "TechCrunch",
            imageUrl: ""
        ),
        BreakingNewsItem(
            category: "Web Development",
            headline: "React 19 officially enters stable release",
            source: "Dev.to",
            imageUrl: ""
        ),
        BreakingNewsItem(
            category: "Mobile Engineering",
            headline: "Apple announces Swift 6 with strict concurrency",
            source: "9to5Mac",
            imageUrl: ""
        ),
        BreakingNewsItem(
            category: "Cybersecurity",
            headline: "Zero-day vulnerability found in major browser engine",
            source: "Wired",
            imageUrl: ""
        )
    ]
    
    // MARK: - Dev Toolkits
    let devToolkits: [DevToolkit] = [
        DevToolkit(
            name: "SwiftUI",
            icon: "swift",
            color: .systemOrange,
            keywords: ["swift", "swiftui", "ios", "apple", "xcode", "mobile"]
        ),
        DevToolkit(
            name: "Python DS",
            icon: "chart.bar.fill",
            color: .systemBlue,
            keywords: ["python", "data", "machine learning", "ai", "pandas", "numpy", "analytics"]
        ),
        DevToolkit(
            name: "Node.js",
            icon: "terminal.fill",
            color: .systemGreen,
            keywords: ["node", "javascript", "js", "npm", "backend", "express", "api"]
        ),
        DevToolkit(
            name: "Docker",
            icon: "shippingbox.fill",
            color: .systemCyan,
            keywords: ["docker", "container", "kubernetes", "deployment", "devops", "k8s"]
        ),
        DevToolkit(
            name: "AWS Cloud",
            icon: "cloud.fill",
            color: UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0),
            keywords: ["aws", "cloud", "amazon", "ec2", "s3", "lambda", "serverless"]
        ),
        DevToolkit(
            name: "Kubernetes",
            icon: "cube.fill",
            color: UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
            keywords: ["kubernetes", "k8s", "container", "orchestration", "docker", "cluster"]
        )
    ]
    
    // MARK: - Technical Briefs (INCLUDING BREAKING NEWS CONTENT)
    let topChoices: [TopChoiceItem] = [
        // BREAKING NEWS ITEMS (Index 0-3)
        TopChoiceItem(
            title: "OpenAI launches GPT-5 with multimodal reasoning",
            date: "23 DEC 25",
            summary: "Revolutionary AI model combines text, images, and code understanding.",
            category: "Artificial Intelligence",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "23 DEC 25")
        ),
        TopChoiceItem(
            title: "React 19 officially enters stable release",
            date: "23 DEC 25",
            summary: "New React Compiler and Server Components arrive in production-ready release.",
            category: "Web Development",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "23 DEC 25")
        ),
        TopChoiceItem(
            title: "Apple announces Swift 6 with strict concurrency",
            date: "23 DEC 25",
            summary: "Enhanced memory safety and data-race prevention in the latest Swift version.",
            category: "Mobile Engineering",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "23 DEC 25")
        ),
        TopChoiceItem(
            title: "Zero-day vulnerability found in major browser engine",
            date: "23 DEC 25",
            summary: "Critical security flaw discovered affecting millions of users worldwide.",
            category: "Cybersecurity",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "23 DEC 25")
        ),
        
        // REGULAR TECHNICAL BRIEFS (Index 4+)
        TopChoiceItem(
            title: "SwiftUI State Management Best Practices",
            date: "22 DEC 25",
            summary: "Deep dive into the latest updates and how they impact the development ecosystem.",
            category: "SwiftUI",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "22 DEC 25")
        ),
        TopChoiceItem(
            title: "Python Data Science: Pandas 2.0 Performance",
            date: "21 DEC 25",
            summary: "Exploring the performance improvements in the latest Pandas release.",
            category: "Python DS",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "21 DEC 25")
        ),
        TopChoiceItem(
            title: "Node.js Event Loop Explained",
            date: "20 DEC 25",
            summary: "Understanding the core architecture of Node.js runtime.",
            category: "Node.js",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "20 DEC 25")
        ),
        TopChoiceItem(
            title: "Docker Multi-Stage Builds Optimization",
            date: "19 DEC 25",
            summary: "Reducing container image sizes with advanced build techniques.",
            category: "Docker",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "19 DEC 25")
        ),
        TopChoiceItem(
            title: "AWS Lambda Cold Start Solutions",
            date: "18 DEC 25",
            summary: "Strategies to minimize serverless function initialization time.",
            category: "AWS Cloud",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "18 DEC 25")
        ),
        TopChoiceItem(
            title: "Kubernetes Pod Security Standards",
            date: "17 DEC 25",
            summary: "Implementing security best practices in container orchestration.",
            category: "Kubernetes",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "17 DEC 25")
        ),
        TopChoiceItem(
            title: "Swift Concurrency: Async/Await Patterns",
            date: "16 DEC 25",
            summary: "Modern approaches to asynchronous programming in Swift.",
            category: "SwiftUI",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "16 DEC 25")
        ),
        TopChoiceItem(
            title: "Machine Learning Model Deployment with Python",
            date: "15 DEC 25",
            summary: "End-to-end guide for productionizing ML models.",
            category: "Python DS",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "15 DEC 25")
        ),
        TopChoiceItem(
            title: "Building Scalable APIs with Express.js",
            date: "14 DEC 25",
            summary: "Architecture patterns for high-performance Node applications.",
            category: "Node.js",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "14 DEC 25")
        ),
        TopChoiceItem(
            title: "Docker Compose for Local Development",
            date: "13 DEC 25",
            summary: "Simplifying multi-container application development.",
            category: "Docker",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "13 DEC 25")
        ),
        TopChoiceItem(
            title: "AWS CloudFormation Infrastructure as Code",
            date: "12 DEC 25",
            summary: "Automating cloud resource provisioning and management.",
            category: "AWS Cloud",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "12 DEC 25")
        ),
        TopChoiceItem(
            title: "Kubernetes Helm Charts Deep Dive",
            date: "11 DEC 25",
            summary: "Package management for Kubernetes applications.",
            category: "Kubernetes",
            imageUrl: "",
            publishedDate: DateFormatter.with(format: "dd MMM yy").date(from: "11 DEC 25")
        )
    ]
    
    // MARK: - Transcripts (EXPANDED TO MATCH ALL CONTENT)
    private let transcripts: [String] = [
        // TRANSCRIPT 0: GPT-5 Launch
        """
        Breaking news from OpenAI today as they unveil GPT-5, their most advanced AI model to date. This groundbreaking release represents a major leap forward in artificial intelligence capabilities.
        
        GPT-5 introduces true multimodal reasoning, seamlessly combining understanding of text, images, code, and even audio inputs. The model can now analyze complex visual scenes while generating contextual code, or explain intricate diagrams with unprecedented accuracy.
        
        Early benchmarks show GPT-5 achieving near-human performance on advanced reasoning tasks, including mathematical proofs, scientific analysis, and creative problem-solving. The model's context window has been expanded to 1 million tokens, enabling analysis of entire codebases or lengthy research papers in a single pass.
        
        Developers can access GPT-5 through OpenAI's API starting next month, with pricing competitive to GPT-4. This release is expected to accelerate AI adoption across industries from healthcare to software development.
        """,
        
        // TRANSCRIPT 1: React 19 Release
        """
        The React team has officially released React 19, marking one of the most significant updates to the popular JavaScript library in years.
        
        The centerpiece of this release is the new React Compiler, which automatically optimizes your components without the need for useMemo or useCallback hooks. This means faster applications with less boilerplate code.
        
        Server Components are now production-ready, allowing developers to build hybrid applications that render efficiently on both server and client. This architecture dramatically reduces JavaScript bundle sizes and improves initial page load times.
        
        React 19 also introduces enhanced form handling with built-in actions, improved error boundaries, and better TypeScript integration. The transition path from React 18 is smooth, with comprehensive migration guides and backwards compatibility for most applications.
        
        The web development community has been eagerly awaiting this release, and early adopters report significant performance improvements and developer experience enhancements.
        """,
        
        // TRANSCRIPT 2: Swift 6 Announcement
        """
        Apple has unveiled Swift 6, bringing major improvements to memory safety and concurrency in iOS, macOS, and cross-platform development.
        
        The headline feature is strict concurrency checking, which prevents data races at compile time. This means entire classes of bugs simply cannot exist in Swift 6 code, dramatically improving app stability and reliability.
        
        The Swift 6 compiler introduces a new ownership model that eliminates entire categories of memory management errors. Combined with enhanced async/await patterns, developers can write safer concurrent code with confidence.
        
        Migration from Swift 5 is incremental, with a compatibility mode that allows gradual adoption. Major frameworks like SwiftUI and Combine have been updated to take full advantage of Swift 6's safety guarantees.
        
        This release solidifies Swift's position as one of the safest and most performant languages for app development, with particular benefits for large-scale iOS and server-side applications.
        """,
        
        // TRANSCRIPT 3: Browser Vulnerability
        """
        Security researchers have discovered a critical zero-day vulnerability in a major browser engine, affecting hundreds of millions of users worldwide.
        
        The vulnerability, designated CVE-2025-0001, allows attackers to execute arbitrary code through specially crafted web pages. This represents a severe security risk, as simply visiting a malicious website could compromise a user's system.
        
        Browser vendors including Chrome, Edge, and Safari have released emergency patches to address the flaw. Security experts are urging all users to update their browsers immediately, as active exploitation has been detected in the wild.
        
        The vulnerability was discovered during a routine security audit and demonstrates the critical importance of ongoing security research. Organizations should ensure their security teams have deployed the patches and are monitoring for any signs of compromise.
        
        This incident serves as a reminder of the constantly evolving threat landscape and the need for robust security practices in web development and system administration.
        """,
        
        // TRANSCRIPT 4: SwiftUI State Management
        """
        Welcome to today's technical brief on SwiftUI State Management. In modern iOS development, managing state effectively is crucial for building responsive and maintainable applications.
        
        SwiftUI introduces several property wrappers that help manage state: @State for local view state, @Binding for two-way data flow, @ObservedObject and @StateObject for reference types, and @EnvironmentObject for app-wide state.
        
        Best practices include keeping state as local as possible, using @StateObject for object initialization, and leveraging Combine for complex state management. Remember to avoid excessive view updates by properly structuring your data models.
        """,
        
        // TRANSCRIPT 5: Pandas 2.0
        """
        Python's Pandas library version 2.0 brings significant performance improvements. The new PyArrow backend offers 2-5x faster operations for many common data manipulation tasks.
        
        Key improvements include optimized memory usage, faster string operations, and better handling of nullable data types. The integration with Apache Arrow enables zero-copy data sharing between different analytics tools.
        
        Data scientists should consider migrating to PyArrow dtypes for production workloads, especially when dealing with large datasets or requiring interoperability with other data processing frameworks.
        """,
        
        // TRANSCRIPT 6: Node.js Event Loop
        """
        The Node.js event loop is fundamental to understanding JavaScript's asynchronous nature. It enables non-blocking I/O operations despite JavaScript being single-threaded.
        
        The event loop has six phases: timers, pending callbacks, idle/prepare, poll, check, and close callbacks. Understanding these phases helps developers write more efficient asynchronous code.
        
        Common pitfalls include blocking the event loop with CPU-intensive tasks and not properly handling promises. Use worker threads for heavy computation and always handle promise rejections to maintain application stability.
        """,
        
        // TRANSCRIPT 7: Docker Multi-Stage
        """
        Docker multi-stage builds revolutionize container image optimization. By using multiple FROM statements, developers can significantly reduce final image sizes.
        
        The pattern involves using a build stage with all development dependencies, then copying only the necessary artifacts to a minimal runtime image. This approach can reduce image sizes by 70-90% compared to single-stage builds.
        
        Best practices include using official slim or alpine base images, combining RUN commands to minimize layers, and leveraging build cache effectively. Remember to use .dockerignore to exclude unnecessary files from the build context.
        """,
        
        // TRANSCRIPT 8: AWS Lambda Cold Starts
        """
        AWS Lambda cold starts remain a challenge for serverless applications. When a function hasn't been invoked recently, AWS must initialize a new execution environment, causing latency.
        
        Solutions include provisioned concurrency for critical functions, using lighter runtimes like Python or Node.js, minimizing deployment package size, and implementing connection pooling for database access.
        
        Advanced techniques involve using Lambda SnapStart for Java functions, implementing warming strategies, and architecting applications to tolerate occasional cold starts. Consider the cost-performance tradeoff when choosing optimization strategies.
        """,
        
        // TRANSCRIPT 9: Kubernetes Security
        """
        Kubernetes Pod Security Standards provide a framework for enforcing security policies. The three levels—Privileged, Baseline, and Restricted—offer increasing security guarantees.
        
        Baseline policies prevent known privilege escalations, while Restricted policies implement current pod hardening best practices. Use Pod Security Admission to enforce these standards at the namespace level.
        
        Implementation requires careful planning: audit existing workloads, apply policies gradually, and use exemptions sparingly. Remember that security is a continuous process requiring regular reviews and updates.
        """
    ]
    
    // MARK: - Helper Methods
    
    /// Get filtered briefs based on toolkit name
    func getFilteredBriefs(for toolkitName: String) -> [TopChoiceItem] {
        guard let toolkit = devToolkits.first(where: { $0.name.lowercased() == toolkitName.lowercased() }) else {
            return topChoices
        }
        
        let filtered = topChoices.filter { item in
            let title = item.title.lowercased()
            let category = item.category.lowercased()
            return toolkit.keywords.contains { keyword in
                title.contains(keyword) || category.contains(keyword)
            }
        }
        
        return filtered.isEmpty ? topChoices : filtered
    }
    
    /// Get toolkit by name
    func getToolkit(named: String) -> DevToolkit? {
        return devToolkits.first { $0.name.lowercased() == named.lowercased() }
    }
    
    /// Get full transcript by index
    func getFullTranscript(for index: Int) -> String {
        guard index >= 0 && index < transcripts.count else {
            return "Transcript not available."
        }
        return transcripts[index]
    }
    
    /// Get all transcripts
    func getAllTranscripts() -> [String] {
        return transcripts
    }
}
