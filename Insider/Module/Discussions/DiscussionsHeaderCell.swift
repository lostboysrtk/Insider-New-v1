import UIKit

class DiscussionsHeaderCell: UITableViewCell {

    // MARK: - Programmatic UI Elements
    let replyCountCellView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 20
        view.layer.cornerCurve = .continuous
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        return view
    }()
    
    let chartView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let replyCount: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.text = "Activity overview"
        return label
    }()
    
    weak var delegate: DiscussionsHeaderDelegate?
    
    // DATA: 15 Days (Days 2 to 16)
    private var replyData: [CGFloat] = Array(repeating: 0, count: 15)
    private var barLayers: [CAGradientLayer] = []
    private var dateLabels: [UILabel] = []
    
    func configure(with data: [CGFloat]) {
        self.replyData = data
        self.setNeedsLayout()
    }
    private var selectionLine: UIView?
    private var valueLabel: UILabel?
    private var selectedBarIndex: Int?
    private let feedbackGenerator = UISelectionFeedbackGenerator()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupConstraints()
        setupInteractions()
        setupOverlayViews()
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupHierarchy() {
        contentView.addSubview(replyCountCellView)
        replyCountCellView.addSubview(chartView)
        replyCountCellView.addSubview(replyCount)
    }

    private func setupConstraints() {
        [replyCountCellView, chartView, replyCount].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            // Align to 0 to let .insetGrouped handle the side margins
            replyCountCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            replyCountCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            replyCountCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            replyCountCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            // Expanded chartView horizontally (0 padding) to align with card borders
            chartView.topAnchor.constraint(equalTo: replyCountCellView.topAnchor, constant: 20),
            chartView.leadingAnchor.constraint(equalTo: replyCountCellView.leadingAnchor, constant: 0),
            chartView.trailingAnchor.constraint(equalTo: replyCountCellView.trailingAnchor, constant: 0),
            chartView.heightAnchor.constraint(equalToConstant: 160),
            
            replyCount.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 12),
            replyCount.centerXAnchor.constraint(equalTo: replyCountCellView.centerXAnchor),
            replyCount.bottomAnchor.constraint(equalTo: replyCountCellView.bottomAnchor, constant: -16)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawStocksChart(in: chartView)
    }

    func drawStocksChart(in view: UIView) {
        barLayers.forEach { $0.removeFromSuperlayer() }
        barLayers.removeAll()
        dateLabels.forEach { $0.removeFromSuperview() }
        dateLabels.removeAll()
        view.layer.sublayers?.filter { $0 is CAShapeLayer && $0.name == "GridLine" }.forEach { $0.removeFromSuperlayer() }
        
        let width = view.bounds.width
        let height = view.bounds.height
        if width <= 0 || height <= 0 { return }
        
        let labelHeight: CGFloat = 20
        let graphHeight = height - labelHeight
        
        // Horizontal padding inside the expanded chart view
        let sidePadding: CGFloat = 16
        let availableWidth = width - (sidePadding * 2)
        
        drawGridLines(in: view, width: width, height: graphHeight)
        
        let count = CGFloat(replyData.count)
        let spacing: CGFloat = 6
        let barWidth = (availableWidth - (spacing * (count - 1))) / count
        let maxValue = max(replyData.max() ?? 1, 1) // Prevent division by zero
        let graphColor = UIColor(hexString: "#5880bf")
        
        for (i, value) in replyData.enumerated() {
            let barHeight = (value / maxValue) * graphHeight
            let xPos = sidePadding + CGFloat(i) * (barWidth + spacing)
            
            let gradient = CAGradientLayer()
            if barHeight > 0 {
                gradient.frame = CGRect(x: xPos, y: graphHeight - barHeight, width: barWidth, height: barHeight)
                gradient.colors = [graphColor.cgColor, graphColor.withAlphaComponent(0.6).cgColor]
                gradient.cornerRadius = 4
                view.layer.insertSublayer(gradient, at: 0)
                barLayers.append(gradient)
            } else {
                // Keep an invisible zero-height layer for gesture detection mapping
                gradient.frame = CGRect(x: xPos, y: graphHeight, width: barWidth, height: 0)
                gradient.opacity = 0
                view.layer.insertSublayer(gradient, at: 0)
                barLayers.append(gradient)
            }
            
            let label = UILabel()
            
            // Format actual date (14 is today, 0 is 14 days ago)
            let daysAgo = 14 - i
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "d" // Just the day number to fit gracefully
            label.text = formatter.string(from: date)
            
            label.font = .systemFont(ofSize: 10, weight: .bold)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.frame = CGRect(x: xPos - 2, y: graphHeight + 4, width: barWidth + 4, height: 14)
            view.addSubview(label)
            dateLabels.append(label)
        }
    }

    func drawGridLines(in view: UIView, width: CGFloat, height: CGFloat) {
        for i in 0..<3 {
            let y = (height / 2) * CGFloat(i)
            let line = CAShapeLayer()
            line.name = "GridLine"
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: width, y: y))
            line.path = path.cgPath; line.strokeColor = UIColor.systemGray5.cgColor
            line.lineDashPattern = [4, 4]; line.lineWidth = 1
            view.layer.insertSublayer(line, at: 0)
        }
    }

    func setupInteractions() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleTouch(_:)))
        chartView.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTouch(_:)))
        chartView.addGestureRecognizer(tap)
    }

    func setupOverlayViews() {
        let line = UIView(); line.backgroundColor = .systemGray; line.isHidden = true
        chartView.addSubview(line); self.selectionLine = line
        let label = UILabel(); label.backgroundColor = .label; label.textColor = .systemBackground
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center; label.layer.cornerRadius = 6; label.clipsToBounds = true; label.isHidden = true
        chartView.addSubview(label); self.valueLabel = label
    }

    @objc func handleTouch(_ gesture: UIGestureRecognizer) {
        let loc = gesture.location(in: chartView)
        var index = -1
        var minDist: CGFloat = 1000
        for (i, layer) in barLayers.enumerated() {
            let dist = abs(loc.x - layer.frame.midX)
            if dist < minDist && dist < 30 { minDist = dist; index = i }
        }
        if gesture.state == .began || gesture.state == .changed { if index != -1 { showOverlay(at: index) } }
        else if gesture.state == .ended {
            if index != -1 {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                // Pass the actual daysAgo value to easily fetch that specific date's articles
                let daysAgo = 14 - index
                delegate?.didTapGraphDay(dayIndex: daysAgo)
            }
            hideOverlay()
        } else { hideOverlay() }
    }

    func showOverlay(at index: Int) {
        let layer = barLayers[index]
        selectionLine?.isHidden = false
        selectionLine?.frame = CGRect(x: layer.frame.midX, y: 0, width: 1, height: chartView.bounds.height - 20)
        valueLabel?.isHidden = false
        valueLabel?.text = " \(Int(replyData[index])) "
        valueLabel?.sizeToFit()
        valueLabel?.center = CGPoint(x: layer.frame.midX, y: -15)
        barLayers.forEach { $0.opacity = 0.4 }; layer.opacity = 1.0
    }

    func hideOverlay() {
        selectionLine?.isHidden = true; valueLabel?.isHidden = true
        barLayers.forEach { $0.opacity = 1.0 }
    }
}

// MARK: - Hex Color Helper
extension UIColor {
    convenience init(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") { hexSanitized.remove(at: hexSanitized.startIndex) }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgb & 0x0000FF) / 255.0,
                  alpha: 1.0)
    }
}
