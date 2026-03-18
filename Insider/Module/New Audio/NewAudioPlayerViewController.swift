import UIKit
import AVFoundation
import MediaPlayer

class NewAudioPlayerViewController: UIViewController {
    /// List of all audio briefs for navigation, can be set externally
    public var allBriefsList: [TopChoiceItem]?

    // MARK: - Data Properties
    var newsItem: TopChoiceItem?
    var transcriptIndex: Int = 0
    private var isTranscriptVisible = false
    private var fullArticleContent: String = ""
    
    // MARK: - Playback State
    private var isPlaying = false
    private var currentTime: Float = 0.0
    private var duration: Float = 180.0
    private var isSeeking = false
    private var playbackTimer: Timer?
    private var allBriefs: [TopChoiceItem] = []
    private var currentBriefIndex: Int = 0
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    // MARK: - AVFoundation
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    private var audioSession: AVAudioSession?
    
    // AVAudioEngine anchor to force Simulator media controls visibility
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    private var silentBuffer: AVAudioPCMBuffer?
    // MARK: - UI Components (Clean UI without Gradients)
    private let transcriptBox = UIView()
    private let albumArtContainer = UIView()
    private let albumArt = UIImageView()
    private let titleLabel = UILabel()
    private let sourceLabel = UILabel()
    private let playbackSlider = UISlider()
    private let currentTimeLabel = UILabel()
    private let remainingTimeLabel = UILabel()
    private let playPauseBtn = UIButton()
    private let backwardBtn = UIButton()
    private let forwardBtn = UIButton()
    private let transcriptToggle = UIButton()
    private let transcriptTextView = UITextView()
    private let moreBtn = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        setupAudioSession()
        setupSilentAudioAnchor()
        setupRemoteCommandCenter()
        setupData()
        setupAestheticUI()
        setupActions()
        updateUI()
        setupNotifications()
        setupGestures()
        
        speechSynthesizer.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        if type == .began {
            if isPlaying {
                pauseSpeech()
            }
        } else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    startSpeech()
                }
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Setup Methods
    
    private func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            // Updated category to .default for better Now Playing reliability in Simulator
            try audioSession?.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession?.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupSilentAudioAnchor() {
        // Generates a programmatic silent buffer to 'anchor' the media session.
        // This fixes the 'mBuffers[0].mDataByteSize (0)' error in the simulator.
        let mainMixer = audioEngine.mainMixerNode
        audioEngine.attach(audioPlayerNode)
        
        let format = mainMixer.outputFormat(forBus: 0)
        audioEngine.connect(audioPlayerNode, to: mainMixer, format: format)
        
        let frameCount = AVAudioFrameCount(format.sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        // Fill with zeroes
        if let data = buffer.floatChannelData {
            for i in 0..<Int(format.channelCount) {
                memset(data[i], 0, Int(frameCount) * MemoryLayout<Float>.size)
            }
        }
        silentBuffer = buffer
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start AVAudioEngine anchor: \(error)")
        }
    }
    
    private func loadArticleContent() {
        guard let item = newsItem else {
            fullArticleContent = AudioDataStore.shared.getFullTranscript(for: transcriptIndex)
            return
        }
        fullArticleContent = AudioDataStore.shared.getArticleContent(for: item, fallbackIndex: transcriptIndex)
    }
    
    private func calculateDuration() {
        let words = fullArticleContent.components(separatedBy: .whitespacesAndNewlines).count
        let estimatedSeconds = Float(words) / 2.5
        self.duration = max(estimatedSeconds, 30.0)
        playbackSlider.maximumValue = self.duration
    }
    
    private func startSpeech(atOffset characterOffset: Int = 0) {
        // Ensure session is active before speaking
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            // Start the silent anchor to 'wake up' the system media controls
            if let buffer = silentBuffer {
                audioPlayerNode.play()
                audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            }
        } catch { }
        
        if backgroundTask == .invalid {
            backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.endBackgroundTask()
            }
        }
        
        if speechSynthesizer.isPaused && characterOffset == 0 {
            speechSynthesizer.continueSpeaking()
        } else {
            if fullArticleContent.isEmpty { return }
            
            // If we are seeking or starting fresh, we must stop first
            if speechSynthesizer.isSpeaking || speechSynthesizer.isPaused {
                speechSynthesizer.stopSpeaking(at: .immediate)
            }

            let textToSpeak = characterOffset > 0 ? String(fullArticleContent.dropFirst(characterOffset)) : fullArticleContent
            if textToSpeak.isEmpty { return }

            let utterance = AVSpeechUtterance(string: textToSpeak)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US") ?? AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0
            
            speechSynthesizer.speak(utterance)
        }
        isPlaying = true
        MPNowPlayingInfoCenter.default().playbackState = .playing
        updateNowPlayingInfo()
    }
    
    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }

    private func pauseSpeech() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.pauseSpeaking(at: .immediate)
        }
        audioPlayerNode.pause()
        isPlaying = false
        MPNowPlayingInfoCenter.default().playbackState = .paused
        updateNowPlayingInfo()
        endBackgroundTask()
    }

    private func stopSpeech() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        setupTranscriptBox()
        endBackgroundTask()
    }
    
    private func setupData() {
        allBriefs = allBriefsList ?? AudioDataStore.shared.topChoices
        
        if let item = newsItem {
            if let index = allBriefs.firstIndex(where: { $0.title == item.title }) {
                currentBriefIndex = index
                transcriptIndex = index
            } else {
                currentBriefIndex = transcriptIndex
            }
        }
        
        loadArticleContent()
        calculateDuration()
    }
    
    private func setupAestheticUI() {
        let brandIndigo: UIColor = .brand
        view.backgroundColor = .systemBackground
        
        // Removed Gradient logic
        
//        blurView.frame = view.bounds
//        blurView.alpha = 0.3
//        view.addSubview(blurView)
        
        setupTranscriptBox()
        
        albumArtContainer.backgroundColor = .secondarySystemBackground
        albumArtContainer.layer.cornerRadius = 20
        albumArtContainer.layer.shadowColor = UIColor.black.cgColor
        albumArtContainer.layer.shadowOpacity = 0.15
        albumArtContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        albumArtContainer.layer.shadowRadius = 20
        
        albumArt.layer.cornerRadius = 20
        albumArt.clipsToBounds = true
        albumArt.contentMode = .scaleAspectFill
        albumArt.image = UIImage(systemName: "waveform.circle.fill")
        albumArt.tintColor = brandIndigo
        
        titleLabel.text = newsItem?.title ?? "Technical Brief"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        
        sourceLabel.text = newsItem?.date ?? "25 OCT 25"
        sourceLabel.textColor = .secondaryLabel
        
        currentTimeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        currentTimeLabel.textColor = .secondaryLabel
        currentTimeLabel.text = "0:00"
        
        remainingTimeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        remainingTimeLabel.textColor = .secondaryLabel
        remainingTimeLabel.textAlignment = .right
        remainingTimeLabel.text = String(format: "-%d:%02d", Int(duration) / 60, Int(duration) % 60)
        
        setupButtons(brandColor: brandIndigo)
        
        let dismissIcon = UIButton(type: .system)
        dismissIcon.setImage(UIImage(systemName: "chevron.compact.down"), for: .normal)
        dismissIcon.tintColor = .systemGray2
        dismissIcon.addTarget(self, action: #selector(dismissPlayer), for: .touchUpInside)
        
        // Removed shuffleBtn and repeatBtn from subviews
        [dismissIcon, albumArtContainer, titleLabel, sourceLabel,
         currentTimeLabel, remainingTimeLabel,
         playPauseBtn, backwardBtn, forwardBtn,
         moreBtn, transcriptToggle].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Add slider LAST so it's on top of everything in the z-order 
        playbackSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playbackSlider)
        playbackSlider.isUserInteractionEnabled = true
        
        albumArtContainer.addSubview(albumArt)
        albumArt.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints(dismissIcon: dismissIcon)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        // Map the range back to the full content if we truncated it during seeking
        let totalOffset = fullArticleContent.count - utterance.speechString.count
        let absoluteRange = NSRange(location: characterRange.location + totalOffset, length: characterRange.length)
        
        let fullText = fullArticleContent
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttributes([
            .foregroundColor: UIColor.label.withAlphaComponent(0.25),
            .font: UIFont.systemFont(ofSize: 28, weight: .medium)
        ], range: NSRange(location: 0, length: fullText.count))
        
        attributedString.addAttributes([
            .foregroundColor: UIColor.label.withAlphaComponent(0.7)
        ], range: NSRange(location: 0, length: absoluteRange.location))
        
        attributedString.addAttributes([
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ], range: absoluteRange)
        
        DispatchQueue.main.async {
            self.transcriptTextView.attributedText = attributedString
            self.transcriptTextView.scrollRangeToVisible(absoluteRange)
            
            // Calibrate the timer-driven currentTime with real speech progress
            if !self.isSeeking {
                let speechProgress = (Float(absoluteRange.location) / Float(fullText.count)) * self.duration
                self.currentTime = speechProgress
                self.playbackSlider.value = speechProgress
                self.updateTimeLabels()
            }
            
            if Int(self.currentTime) % 2 == 0 {
                self.updateNowPlayingInfo()
            }
        }
    }

    private func setupTranscriptBox() {
        transcriptBox.alpha = 0
        transcriptBox.backgroundColor = .clear
        transcriptBox.isUserInteractionEnabled = false
        
        transcriptTextView.backgroundColor = .clear
        transcriptTextView.textColor = .label
        transcriptTextView.font = .systemFont(ofSize: 28, weight: .semibold)
        transcriptTextView.isEditable = false
        transcriptTextView.isScrollEnabled = true
        transcriptTextView.showsVerticalScrollIndicator = false
        
        view.addSubview(transcriptBox)
        transcriptBox.addSubview(transcriptTextView)
        
        transcriptBox.translatesAutoresizingMaskIntoConstraints = false
        transcriptTextView.translatesAutoresizingMaskIntoConstraints = false
        
        transcriptTextView.attributedText = NSAttributedString(
            string: fullArticleContent,
            attributes: [
                .foregroundColor: UIColor.label.withAlphaComponent(0.3),
                .font: UIFont.systemFont(ofSize: 28, weight: .semibold)
            ]
        )
    }
    
    private func setupButtons(brandColor: UIColor) {
        let mainConfig = UIImage.SymbolConfiguration(pointSize: 54, weight: .semibold)
        let sideConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold)
        
        playPauseBtn.setImage(UIImage(systemName: "play.fill", withConfiguration: mainConfig), for: .normal)
        playPauseBtn.tintColor = brandColor
        
        backwardBtn.setImage(UIImage(systemName: "backward.fill", withConfiguration: sideConfig), for: .normal)
        forwardBtn.setImage(UIImage(systemName: "forward.fill", withConfiguration: sideConfig), for: .normal)
        
        transcriptToggle.setImage(UIImage(systemName: "quote.bubble"), for: .normal)
        moreBtn.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
        
        playbackSlider.minimumTrackTintColor = brandColor
        playbackSlider.maximumTrackTintColor = .systemGray5
        playbackSlider.maximumValue = duration
        playbackSlider.value = 0
        playbackSlider.isContinuous = true
        playbackSlider.isUserInteractionEnabled = true
        
        [backwardBtn, forwardBtn, moreBtn, transcriptToggle].forEach {
            $0.tintColor = .label
        }
    }
    
    private func setupActions() {
        playPauseBtn.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        backwardBtn.addTarget(self, action: #selector(previousTrack), for: .touchUpInside)
        forwardBtn.addTarget(self, action: #selector(nextTrack), for: .touchUpInside)
        transcriptToggle.addTarget(self, action: #selector(toggleTranscript), for: .touchUpInside)
        moreBtn.addTarget(self, action: #selector(showMoreOptions), for: .touchUpInside)
        
        playbackSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        playbackSlider.addTarget(self, action: #selector(sliderTouchBegan), for: .touchDown)
        playbackSlider.addTarget(self, action: #selector(sliderTouchEnded), for: [.touchUpInside, .touchUpOutside])
        

    }
    
    // MARK: - Remote Control & Metadata
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if !self.isPlaying {
                self.playPauseTapped()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.isPlaying {
                self.playPauseTapped()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.nextTrack()
            return .success
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.previousTrack()
            return .success
        }
        
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.currentTime = min(self.currentTime + 15, self.duration)
            self.playbackSlider.value = self.currentTime
            self.updateTimeLabels()
            self.updateNowPlayingInfo()
            return .success
        }
        
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.currentTime = max(self.currentTime - 15, 0)
            self.playbackSlider.value = self.currentTime
            self.updateTimeLabels()
            self.updateNowPlayingInfo()
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        guard let item = newsItem else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = item.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Insider"
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Technical Briefs"
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        
        let artworkImage = albumArt.image ?? UIImage(systemName: "waveform.circle.fill")
        if let image = artworkImage {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        
        // Critical for Dynamic Island and Lock Screen progress syncing
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = false
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        // Sync the explicit playback state again to be double sure
        MPNowPlayingInfoCenter.default().playbackState = isPlaying ? .playing : .paused
    }
    
    // MARK: - Playback Control Actions
    @objc private func playPauseTapped() {
        isPlaying.toggle()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .semibold)
        let icon = isPlaying ? "pause.fill" : "play.fill"
        playPauseBtn.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
        
        if isPlaying {
            startPlayback()
            startSpeech()
        } else {
            stopPlayback()
            pauseSpeech()
        }
    }
    
    @objc private func previousTrack() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        if currentTime > 3.0 {
            currentTime = 0
            playbackSlider.value = 0
            updateTimeLabels()
            return
        }
        
        if currentBriefIndex > 0 {
            currentBriefIndex -= 1
        } else {
            return
        }
        
        loadNewTrack()
    }
    
    @objc private func nextTrack() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        if currentBriefIndex < allBriefs.count - 1 {
            currentBriefIndex += 1
        } else {
            return
        }
        
        loadNewTrack()
    }
    
    @objc private func toggleTranscript() {
        isTranscriptVisible.toggle()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.transcriptBox.alpha = self.isTranscriptVisible ? 1 : 0
            self.transcriptBox.isUserInteractionEnabled = self.isTranscriptVisible
            self.transcriptBox.transform = self.isTranscriptVisible ? .identity : CGAffineTransform(scaleX: 0.9, y: 0.9)
            
            self.albumArtContainer.alpha = self.isTranscriptVisible ? 0.05 : 1
            self.albumArtContainer.transform = self.isTranscriptVisible ? CGAffineTransform(scaleX: 0.7, y: 0.7) : .identity
            
            self.transcriptToggle.tintColor = self.isTranscriptVisible ? .brand : .label
        }
    }
    
    @objc private func showMoreOptions() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let alert = UIAlertController(title: newsItem?.title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add to Favorites", style: .default) { _ in })
        alert.addAction(UIAlertAction(title: "Share", style: .default) { _ in })
        alert.addAction(UIAlertAction(title: "View Full Article", style: .default) { _ in
            self.showFullTranscript()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showFullTranscript() {
        let transcriptVC = TechnicalTranscriptViewController()
        transcriptVC.newsItem = allBriefs[currentBriefIndex]
        transcriptVC.transcriptIndex = currentBriefIndex
        transcriptVC.fullArticleContent = fullArticleContent
        
        let navVC = UINavigationController(rootViewController: transcriptVC)
        present(navVC, animated: true)
    }
    
    // MARK: - Slider Actions
    @objc private func sliderValueChanged(_ sender: UISlider) {
        currentTime = sender.value
        updateTimeLabels()
    }
    
    @objc private func sliderTouchBegan() {
        isSeeking = true
        // Pause the timer while user is dragging
        stopPlayback()
        if isPlaying {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    @objc private func sliderTouchEnded() {
        isSeeking = false
        currentTime = playbackSlider.value
        updateTimeLabels()
        
        if currentTime >= duration - 3 {
            handleTrackEnd()
            return
        }
        
        if isPlaying {
            // Resume from the new position
            startPlayback()
            let ratio = currentTime / duration
            let characterOffset = Int(Float(fullArticleContent.count) * ratio)
            startSpeech(atOffset: characterOffset)
        }
    }
    

    
    @objc private func dismissPlayer() {
        stopPlayback()
        stopSpeech()
        dismiss(animated: true)
    }
    
    // MARK: - Gestures
    private var initialViewCenter: CGPoint = .zero
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            initialViewCenter = view.center
        case .changed:
            // Only allow pull down
            if translation.y > 0 {
                view.center = CGPoint(x: initialViewCenter.x, y: initialViewCenter.y + translation.y)
            }
        case .ended, .cancelled:
            if translation.y > 150 || gesture.velocity(in: view).y > 500 {
                dismissPlayer()
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    self.view.center = self.initialViewCenter
                }, completion: nil)
            }
        default:
            break
        }
    }
    

    

    
    // MARK: - Playback Management
    
    private func startPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, !self.isSeeking else { return }
            self.currentTime += 0.1
            if self.currentTime >= self.duration {
                self.handleTrackEnd()
            } else {
                self.playbackSlider.value = self.currentTime
                self.updateTimeLabels()
            }
        }
    }
    
    private func stopPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    private func handleTrackEnd() {
        if currentBriefIndex < allBriefs.count - 1 {
            nextTrack()
        } else {
            isPlaying = false
            currentTime = 0
            playbackSlider.value = 0
            updateTimeLabels()
            
            let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .semibold)
            playPauseBtn.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
            stopPlayback()
            stopSpeech()
            MPNowPlayingInfoCenter.default().playbackState = .stopped
            updateNowPlayingInfo()
        }
    }
    
    private func loadNewTrack() {
        stopPlayback()
        stopSpeech()
        
        newsItem = allBriefs[currentBriefIndex]
        transcriptIndex = currentBriefIndex
        currentTime = 0
        
        loadArticleContent()
        calculateDuration()
        
        playbackSlider.value = 0
        updateUI()
        
        if isPlaying {
            startPlayback()
            startSpeech()
        }
    }
    
    private func updateUI() {
        titleLabel.text = newsItem?.title ?? "Technical Brief"
        sourceLabel.text = newsItem?.date ?? "Date"
        
        transcriptTextView.attributedText = NSAttributedString(
            string: fullArticleContent,
            attributes: [
                .foregroundColor: UIColor.label.withAlphaComponent(0.3),
                .font: UIFont.systemFont(ofSize: 28, weight: .semibold)
            ]
        )
        
        updateTimeLabels()
        updateNowPlayingInfo()
    }
    
    private func updateTimeLabels() {
        let current = Int(currentTime)
        let remaining = Int(duration - currentTime)
        currentTimeLabel.text = String(format: "%d:%02d", current / 60, current % 60)
        remainingTimeLabel.text = String(format: "-%d:%02d", remaining / 60, remaining % 60)
    }

    // MARK: - Layout
    private func setupConstraints(dismissIcon: UIButton) {
        // Removed shuffle and repeat constraints
        NSLayoutConstraint.activate([
            dismissIcon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dismissIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            albumArtContainer.topAnchor.constraint(equalTo: dismissIcon.bottomAnchor, constant: 40),
            albumArtContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            albumArtContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            albumArtContainer.heightAnchor.constraint(equalTo: albumArtContainer.widthAnchor),
            
            albumArt.topAnchor.constraint(equalTo: albumArtContainer.topAnchor),
            albumArt.leadingAnchor.constraint(equalTo: albumArtContainer.leadingAnchor),
            albumArt.trailingAnchor.constraint(equalTo: albumArtContainer.trailingAnchor),
            albumArt.bottomAnchor.constraint(equalTo: albumArtContainer.bottomAnchor),
            
            transcriptBox.topAnchor.constraint(equalTo: dismissIcon.bottomAnchor, constant: 40),
            transcriptBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            transcriptBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            transcriptBox.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -40),
            
            transcriptTextView.topAnchor.constraint(equalTo: transcriptBox.topAnchor),
            transcriptTextView.leadingAnchor.constraint(equalTo: transcriptBox.leadingAnchor),
            transcriptTextView.trailingAnchor.constraint(equalTo: transcriptBox.trailingAnchor),
            transcriptTextView.bottomAnchor.constraint(equalTo: transcriptBox.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: albumArtContainer.bottomAnchor, constant: 45),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: moreBtn.leadingAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
            
            moreBtn.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            moreBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            moreBtn.widthAnchor.constraint(equalToConstant: 30),
            moreBtn.heightAnchor.constraint(equalToConstant: 30),
            
            sourceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            sourceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            currentTimeLabel.topAnchor.constraint(equalTo: sourceLabel.bottomAnchor, constant: 25),
            currentTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            
            remainingTimeLabel.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),
            remainingTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            playbackSlider.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 8),
            playbackSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            playbackSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            playPauseBtn.topAnchor.constraint(equalTo: playbackSlider.bottomAnchor, constant: 45),
            playPauseBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseBtn.widthAnchor.constraint(equalToConstant: 60),
            playPauseBtn.heightAnchor.constraint(equalToConstant: 60),
            
            backwardBtn.centerYAnchor.constraint(equalTo: playPauseBtn.centerYAnchor),
            backwardBtn.trailingAnchor.constraint(equalTo: playPauseBtn.leadingAnchor, constant: -50),
            
            forwardBtn.centerYAnchor.constraint(equalTo: playPauseBtn.centerYAnchor),
            forwardBtn.leadingAnchor.constraint(equalTo: playPauseBtn.trailingAnchor, constant: 50),
            
            transcriptToggle.topAnchor.constraint(equalTo: playPauseBtn.bottomAnchor, constant: 45),
            transcriptToggle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transcriptToggle.widthAnchor.constraint(equalToConstant: 44),
            transcriptToggle.heightAnchor.constraint(equalToConstant: 44),
            transcriptToggle.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    deinit {
        stopPlayback()
        stopSpeech()
        audioEngine.stop()
        do { try audioSession?.setActive(false) } catch { }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension NewAudioPlayerViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.handleTrackEnd() }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension NewAudioPlayerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Block the pan gesture from receiving touches on any interactive control
        guard let touchedView = touch.view else { return true }
        
        let interactiveControls: [UIView] = [playbackSlider, playPauseBtn, backwardBtn, forwardBtn, transcriptToggle, moreBtn]
        for control in interactiveControls {
            if touchedView == control || touchedView.isDescendant(of: control) {
                return false
            }
        }
        return true
    }
}













//
//import UIKit
//import AVFoundation
//import MediaPlayer
//
//class NewAudioPlayerViewController: UIViewController {
//    /// List of all audio briefs for navigation, can be set externally
//    public var allBriefsList: [TopChoiceItem]?
//
//    // MARK: - Data Properties
//    var newsItem: TopChoiceItem?
//    var transcriptIndex: Int = 0
//    private var isTranscriptVisible = false
//    private var fullArticleContent: String = ""
//    
//    // MARK: - Playback State
//    private var isPlaying = false
//    private var currentTime: Float = 0.0
//    private var duration: Float = 180.0
//    
//    private var playbackTimer: Timer?
//    private var allBriefs: [TopChoiceItem] = []
//    private var currentBriefIndex: Int = 0
//    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
//    
//    // MARK: - AVFoundation
//    private let speechSynthesizer = AVSpeechSynthesizer()
//    private var currentUtterance: AVSpeechUtterance?
//    private var audioSession: AVAudioSession?
//    
//    // AVAudioEngine anchor to force Simulator media controls visibility
//    private let audioEngine = AVAudioEngine()
//    private let audioPlayerNode = AVAudioPlayerNode()
//    private var silentBuffer: AVAudioPCMBuffer?
//    
//    // MARK: - UI Components
//    private let transcriptBox = UIView()
//    private let albumArtContainer = UIView()
//    private let albumArt = UIImageView()
//    private let titleLabel = UILabel()
//    private let sourceLabel = UILabel()
//    private let playbackSlider = UISlider()
//    private let currentTimeLabel = UILabel()
//    private let remainingTimeLabel = UILabel()
//    private let playPauseBtn = UIButton()
//    private let backwardBtn = UIButton()
//    private let forwardBtn = UIButton()
//    private let transcriptToggle = UIButton()
//    private let transcriptTextView = UITextView()
//    private let moreBtn = UIButton()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        UIApplication.shared.beginReceivingRemoteControlEvents()
//        setupAudioSession()
//        setupSilentAudioAnchor()
//        setupRemoteCommandCenter()
//        setupData()
//        setupAestheticUI()
//        setupActions()
//        updateUI()
//        setupNotifications()
//        setupGestures()
//        
//        speechSynthesizer.delegate = self
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        becomeFirstResponder()
//    }
//    
//    private func setupNotifications() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleInterruption),
//                                               name: AVAudioSession.interruptionNotification,
//                                               object: AVAudioSession.sharedInstance())
//    }
//    
//    @objc private func handleInterruption(notification: Notification) {
//        guard let userInfo = notification.userInfo,
//              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
//              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
//        
//        if type == .began {
//            if isPlaying {
//                pauseSpeech()
//            }
//        } else if type == .ended {
//            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
//                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
//                if options.contains(.shouldResume) {
//                    startSpeech()
//                }
//            }
//        }
//    }
//    
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
//    
//    // MARK: - Setup Methods
//    
//    private func setupAudioSession() {
//        audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession?.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
//            try audioSession?.setActive(true)
//        } catch {
//            print("Failed to set up audio session: \(error)")
//        }
//    }
//    
//    private func setupSilentAudioAnchor() {
//        let mainMixer = audioEngine.mainMixerNode
//        audioEngine.attach(audioPlayerNode)
//        
//        let format = mainMixer.outputFormat(forBus: 0)
//        audioEngine.connect(audioPlayerNode, to: mainMixer, format: format)
//        
//        let frameCount = AVAudioFrameCount(format.sampleRate)
//        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
//        buffer.frameLength = frameCount
//        
//        if let data = buffer.floatChannelData {
//            for i in 0..<Int(format.channelCount) {
//                memset(data[i], 0, Int(frameCount) * MemoryLayout<Float>.size)
//            }
//        }
//        silentBuffer = buffer
//        
//        do {
//            try audioEngine.start()
//        } catch {
//            print("Failed to start AVAudioEngine anchor: \(error)")
//        }
//    }
//    
//    private func loadArticleContent() {
//        guard let item = newsItem else {
//            fullArticleContent = AudioDataStore.shared.getFullTranscript(for: transcriptIndex)
//            return
//        }
//        fullArticleContent = AudioDataStore.shared.getArticleContent(for: item, fallbackIndex: transcriptIndex)
//    }
//    
//    private func calculateDuration() {
//        let words = fullArticleContent.components(separatedBy: .whitespacesAndNewlines).count
//        let estimatedSeconds = Float(words) / 2.5
//        self.duration = max(estimatedSeconds, 30.0)
//        playbackSlider.maximumValue = self.duration
//    }
//    
//    private func startSpeech() {
//        do {
//            try AVAudioSession.sharedInstance().setActive(true)
//            if let buffer = silentBuffer {
//                audioPlayerNode.play()
//                audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
//            }
//        } catch { }
//        
//        if backgroundTask == .invalid {
//            backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
//                self?.endBackgroundTask()
//            }
//        }
//        
//        if speechSynthesizer.isPaused {
//            speechSynthesizer.continueSpeaking()
//        } else {
//            if fullArticleContent.isEmpty { return }
//
//            let utterance = AVSpeechUtterance(string: fullArticleContent)
//            utterance.voice = AVSpeechSynthesisVoice(language: "en-US") ?? AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
//            utterance.rate = 0.5
//            utterance.pitchMultiplier = 1.0
//            utterance.volume = 1.0
//            
//            speechSynthesizer.speak(utterance)
//        }
//        isPlaying = true
//        MPNowPlayingInfoCenter.default().playbackState = .playing
//        updateNowPlayingInfo()
//    }
//    
//    private func endBackgroundTask() {
//        UIApplication.shared.endBackgroundTask(backgroundTask)
//        backgroundTask = .invalid
//    }
//
//    private func pauseSpeech() {
//        if speechSynthesizer.isSpeaking {
//            speechSynthesizer.pauseSpeaking(at: .immediate)
//        }
//        audioPlayerNode.pause()
//        isPlaying = false
//        MPNowPlayingInfoCenter.default().playbackState = .paused
//        updateNowPlayingInfo()
//        endBackgroundTask()
//    }
//
//    private func stopSpeech() {
//        speechSynthesizer.stopSpeaking(at: .immediate)
//        setupTranscriptBox()
//        endBackgroundTask()
//    }
//    
//    private func setupData() {
//        allBriefs = allBriefsList ?? AudioDataStore.shared.topChoices
//        
//        if let item = newsItem {
//            if let index = allBriefs.firstIndex(where: { $0.title == item.title }) {
//                currentBriefIndex = index
//                transcriptIndex = index
//            } else {
//                currentBriefIndex = transcriptIndex
//            }
//        }
//        
//        loadArticleContent()
//        calculateDuration()
//    }
//    
//    private func setupAestheticUI() {
//        let brandIndigo: UIColor = .brand
//        view.backgroundColor = .systemBackground
//        
//        setupTranscriptBox()
//        
//        albumArtContainer.backgroundColor = .secondarySystemBackground
//        albumArtContainer.layer.cornerRadius = 20
//        albumArtContainer.layer.shadowColor = UIColor.black.cgColor
//        albumArtContainer.layer.shadowOpacity = 0.15
//        albumArtContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
//        albumArtContainer.layer.shadowRadius = 20
//        
//        albumArt.layer.cornerRadius = 20
//        albumArt.clipsToBounds = true
//        albumArt.contentMode = .scaleAspectFill
//        albumArt.image = UIImage(systemName: "waveform.circle.fill")
//        albumArt.tintColor = brandIndigo
//        
//        titleLabel.text = newsItem?.title ?? "Technical Brief"
//        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
//        titleLabel.numberOfLines = 2
//        titleLabel.lineBreakMode = .byTruncatingTail
//        
//        sourceLabel.text = newsItem?.date ?? "25 OCT 25"
//        sourceLabel.textColor = .secondaryLabel
//        
//        currentTimeLabel.font = .systemFont(ofSize: 12, weight: .medium)
//        currentTimeLabel.textColor = .secondaryLabel
//        currentTimeLabel.text = "0:00"
//        
//        remainingTimeLabel.font = .systemFont(ofSize: 12, weight: .medium)
//        remainingTimeLabel.textColor = .secondaryLabel
//        remainingTimeLabel.textAlignment = .right
//        remainingTimeLabel.text = String(format: "-%d:%02d", Int(duration) / 60, Int(duration) % 60)
//        
//        setupButtons(brandColor: brandIndigo)
//        
//        let dismissIcon = UIButton(type: .system)
//        dismissIcon.setImage(UIImage(systemName: "chevron.compact.down"), for: .normal)
//        dismissIcon.tintColor = .systemGray2
//        dismissIcon.addTarget(self, action: #selector(dismissPlayer), for: .touchUpInside)
//        
//        [dismissIcon, albumArtContainer, titleLabel, sourceLabel,
//         currentTimeLabel, remainingTimeLabel, playbackSlider,
//         playPauseBtn, backwardBtn, forwardBtn,
//         moreBtn, transcriptToggle].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview($0)
//        }
//        
//        albumArtContainer.addSubview(albumArt)
//        albumArt.translatesAutoresizingMaskIntoConstraints = false
//        
//        setupConstraints(dismissIcon: dismissIcon)
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
//        let fullText = utterance.speechString
//        let attributedString = NSMutableAttributedString(string: fullText)
//        
//        attributedString.addAttributes([
//            .foregroundColor: UIColor.label.withAlphaComponent(0.25),
//            .font: UIFont.systemFont(ofSize: 28, weight: .medium)
//        ], range: NSRange(location: 0, length: fullText.count))
//        
//        attributedString.addAttributes([
//            .foregroundColor: UIColor.label.withAlphaComponent(0.7)
//        ], range: NSRange(location: 0, length: characterRange.location))
//        
//        attributedString.addAttributes([
//            .foregroundColor: UIColor.label,
//            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
//        ], range: characterRange)
//        
//        DispatchQueue.main.async {
//            self.transcriptTextView.attributedText = attributedString
//            self.transcriptTextView.scrollRangeToVisible(characterRange)
//            
//            let totalLength = Float(fullText.count)
//            let progress = (Float(characterRange.location) / totalLength) * self.duration
//            self.currentTime = progress
//            self.playbackSlider.value = progress
//            self.updateTimeLabels()
//            
//            if Int(self.currentTime) % 2 == 0 {
//                self.updateNowPlayingInfo()
//            }
//        }
//    }
//
//    private func setupTranscriptBox() {
//        transcriptBox.alpha = 0
//        transcriptBox.backgroundColor = .clear
//        
//        transcriptTextView.backgroundColor = .clear
//        transcriptTextView.textColor = .label
//        transcriptTextView.font = .systemFont(ofSize: 28, weight: .semibold)
//        transcriptTextView.isEditable = false
//        transcriptTextView.isScrollEnabled = true
//        transcriptTextView.showsVerticalScrollIndicator = false
//        
//        view.addSubview(transcriptBox)
//        transcriptBox.addSubview(transcriptTextView)
//        
//        transcriptBox.translatesAutoresizingMaskIntoConstraints = false
//        transcriptTextView.translatesAutoresizingMaskIntoConstraints = false
//        
//        transcriptTextView.attributedText = NSAttributedString(
//            string: fullArticleContent,
//            attributes: [
//                .foregroundColor: UIColor.label.withAlphaComponent(0.3),
//                .font: UIFont.systemFont(ofSize: 28, weight: .semibold)
//            ]
//        )
//    }
//    
//    private func setupButtons(brandColor: UIColor) {
//        let mainConfig = UIImage.SymbolConfiguration(pointSize: 54, weight: .semibold)
//        let sideConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold)
//        
//        playPauseBtn.setImage(UIImage(systemName: "play.fill", withConfiguration: mainConfig), for: .normal)
//        playPauseBtn.tintColor = brandColor
//        
//        backwardBtn.setImage(UIImage(systemName: "backward.fill", withConfiguration: sideConfig), for: .normal)
//        forwardBtn.setImage(UIImage(systemName: "forward.fill", withConfiguration: sideConfig), for: .normal)
//        
//        transcriptToggle.setImage(UIImage(systemName: "quote.bubble"), for: .normal)
//        moreBtn.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
//        
//        playbackSlider.minimumTrackTintColor = brandColor
//        playbackSlider.maximumValue = duration
//        playbackSlider.value = 0
//        
//        [backwardBtn, forwardBtn, moreBtn, transcriptToggle].forEach {
//            $0.tintColor = .label
//        }
//    }
//    
//    private func setupActions() {
//        playPauseBtn.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
//        backwardBtn.addTarget(self, action: #selector(previousTrack), for: .touchUpInside)
//        forwardBtn.addTarget(self, action: #selector(nextTrack), for: .touchUpInside)
//        
//        transcriptToggle.addTarget(self, action: #selector(toggleTranscript), for: .touchUpInside)
//        moreBtn.addTarget(self, action: #selector(showMoreOptions), for: .touchUpInside)
//        
//        playbackSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
//        playbackSlider.addTarget(self, action: #selector(sliderTouchBegan), for: .touchDown)
//        playbackSlider.addTarget(self, action: #selector(sliderTouchEnded), for: [.touchUpInside, .touchUpOutside])
//    }
//    
//    // MARK: - Remote Control & Metadata
//    
//    private func setupRemoteCommandCenter() {
//        let commandCenter = MPRemoteCommandCenter.shared()
//        
//        commandCenter.playCommand.isEnabled = true
//        commandCenter.playCommand.addTarget { [weak self] _ in
//            guard let self = self else { return .commandFailed }
//            if !self.isPlaying {
//                self.playPauseTapped()
//                return .success
//            }
//            return .commandFailed
//        }
//        
//        commandCenter.pauseCommand.isEnabled = true
//        commandCenter.pauseCommand.addTarget { [weak self] _ in
//            guard let self = self else { return .commandFailed }
//            if self.isPlaying {
//                self.playPauseTapped()
//                return .success
//            }
//            return .commandFailed
//        }
//        
//        commandCenter.nextTrackCommand.isEnabled = true
//        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
//            guard let self = self else { return .commandFailed }
//            self.nextTrack()
//            return .success
//        }
//        
//        commandCenter.previousTrackCommand.isEnabled = true
//        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
//            guard let self = self else { return .commandFailed }
//            self.previousTrack()
//            return .success
//        }
//        
//        commandCenter.skipForwardCommand.isEnabled = true
//        commandCenter.skipForwardCommand.preferredIntervals = [15]
//        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
//            guard let self = self else { return .commandFailed }
//            self.currentTime = min(self.currentTime + 15, self.duration)
//            self.playbackSlider.value = self.currentTime
//            self.updateTimeLabels()
//            self.updateNowPlayingInfo()
//            return .success
//        }
//        
//        commandCenter.skipBackwardCommand.isEnabled = true
//        commandCenter.skipBackwardCommand.preferredIntervals = [15]
//        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
//            guard let self = self else { return .commandFailed }
//            self.currentTime = max(self.currentTime - 15, 0)
//            self.playbackSlider.value = self.currentTime
//            self.updateTimeLabels()
//            self.updateNowPlayingInfo()
//            return .success
//        }
//    }
//    
//    private func updateNowPlayingInfo() {
//        guard let item = newsItem else { return }
//        
//        var nowPlayingInfo = [String: Any]()
//        nowPlayingInfo[MPMediaItemPropertyTitle] = item.title
//        nowPlayingInfo[MPMediaItemPropertyArtist] = "Insider"
//        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Technical Briefs"
//        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
//        
//        let artworkImage = albumArt.image ?? UIImage(systemName: "waveform.circle.fill")
//        if let image = artworkImage {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
//        }
//        
//        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
//        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
//        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = false
//        
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//        MPNowPlayingInfoCenter.default().playbackState = isPlaying ? .playing : .paused
//    }
//    
//    // MARK: - Playback Control Actions
//    @objc private func playPauseTapped() {
//        isPlaying.toggle()
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//        
//        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .semibold)
//        let icon = isPlaying ? "pause.fill" : "play.fill"
//        playPauseBtn.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
//        
//        if isPlaying {
//            startPlayback()
//            startSpeech()
//        } else {
//            stopPlayback()
//            pauseSpeech()
//        }
//    }
//    
//    @objc private func previousTrack() {
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//        
//        if currentTime > 3.0 {
//            currentTime = 0
//            playbackSlider.value = 0
//            updateTimeLabels()
//            return
//        }
//        
//        if currentBriefIndex > 0 {
//            currentBriefIndex -= 1
//        } else {
//            return
//        }
//        
//        loadNewTrack()
//    }
//    
//    @objc private func nextTrack() {
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//        
//        if currentBriefIndex < allBriefs.count - 1 {
//            currentBriefIndex += 1
//        } else {
//            return
//        }
//        
//        loadNewTrack()
//    }
//    
//    @objc private func toggleTranscript() {
//        isTranscriptVisible.toggle()
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//        
//        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
//            self.transcriptBox.alpha = self.isTranscriptVisible ? 1 : 0
//            self.transcriptBox.transform = self.isTranscriptVisible ? .identity : CGAffineTransform(scaleX: 0.9, y: 0.9)
//            
//            self.albumArtContainer.alpha = self.isTranscriptVisible ? 0.05 : 1
//            self.albumArtContainer.transform = self.isTranscriptVisible ? CGAffineTransform(scaleX: 0.7, y: 0.7) : .identity
//            
//            self.transcriptToggle.tintColor = self.isTranscriptVisible ? .brand : .label
//        }
//    }
//    
//    @objc private func showMoreOptions() {
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//        
//        let alert = UIAlertController(title: newsItem?.title, message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Add to Favorites", style: .default) { _ in })
//        alert.addAction(UIAlertAction(title: "Share", style: .default) { _ in })
//        alert.addAction(UIAlertAction(title: "View Full Article", style: .default) { _ in
//            self.showFullTranscript()
//        })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(alert, animated: true)
//    }
//    
//    @objc private func showFullTranscript() {
//        let transcriptVC = TechnicalTranscriptViewController()
//        transcriptVC.newsItem = allBriefs[currentBriefIndex]
//        transcriptVC.transcriptIndex = currentBriefIndex
//        transcriptVC.fullArticleContent = fullArticleContent
//        
//        let navVC = UINavigationController(rootViewController: transcriptVC)
//        present(navVC, animated: true)
//    }
//    
//    // MARK: - Slider Actions
//    @objc private func sliderValueChanged(_ sender: UISlider) {
//        currentTime = sender.value
//        updateTimeLabels()
//    }
//    
//    @objc private func sliderTouchBegan() {
//        if isPlaying { pauseSpeech() }
//    }
//    
//    @objc private func sliderTouchEnded() {
//        if isPlaying {
//            stopSpeech()
//            currentTime = playbackSlider.value
//            
//            if currentTime >= duration - 5 {
//                handleTrackEnd()
//            } else {
//                startSpeech()
//            }
//        }
//    }
//    
//    @objc private func dismissPlayer() {
//        stopPlayback()
//        stopSpeech()
//        dismiss(animated: true)
//    }
//    
//    // MARK: - Gestures
//    private var initialViewCenter: CGPoint = .zero
//    
//    private func setupGestures() {
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//        panGesture.delegate = self
//        view.addGestureRecognizer(panGesture)
//    }
//    
//    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: view)
//        
//        switch gesture.state {
//        case .began:
//            initialViewCenter = view.center
//        case .changed:
//            if translation.y > 0 {
//                view.center = CGPoint(x: initialViewCenter.x, y: initialViewCenter.y + translation.y)
//            }
//        case .ended, .cancelled:
//            if translation.y > 150 || gesture.velocity(in: view).y > 500 {
//                dismissPlayer()
//            } else {
//                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
//                    self.view.center = self.initialViewCenter
//                }, completion: nil)
//            }
//        default:
//            break
//        }
//    }
//    
//    // MARK: - Playback Management
//    private func startPlayback() {
//        playbackTimer?.invalidate()
//        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            self.currentTime += 0.1
//            if self.currentTime >= self.duration {
//                self.handleTrackEnd()
//            } else {
//                self.playbackSlider.value = self.currentTime
//                self.updateTimeLabels()
//            }
//        }
//    }
//    
//    private func stopPlayback() {
//        playbackTimer?.invalidate()
//        playbackTimer = nil
//    }
//    
//    private func handleTrackEnd() {
//        if currentBriefIndex < allBriefs.count - 1 {
//            nextTrack()
//        } else {
//            isPlaying = false
//            currentTime = 0
//            playbackSlider.value = 0
//            updateTimeLabels()
//            
//            let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .semibold)
//            playPauseBtn.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
//            stopPlayback()
//            stopSpeech()
//            MPNowPlayingInfoCenter.default().playbackState = .stopped
//            updateNowPlayingInfo()
//        }
//    }
//    
//    private func loadNewTrack() {
//        stopPlayback()
//        stopSpeech()
//        
//        newsItem = allBriefs[currentBriefIndex]
//        transcriptIndex = currentBriefIndex
//        currentTime = 0
//        
//        loadArticleContent()
//        calculateDuration()
//        
//        playbackSlider.value = 0
//        updateUI()
//        
//        if isPlaying {
//            startPlayback()
//            startSpeech()
//        }
//    }
//    
//    private func updateUI() {
//        titleLabel.text = newsItem?.title ?? "Technical Brief"
//        sourceLabel.text = newsItem?.date ?? "Date"
//        
//        transcriptTextView.attributedText = NSAttributedString(
//            string: fullArticleContent,
//            attributes: [
//                .foregroundColor: UIColor.label.withAlphaComponent(0.3),
//                .font: UIFont.systemFont(ofSize: 28, weight: .semibold)
//            ]
//        )
//        
//        updateTimeLabels()
//        updateNowPlayingInfo()
//    }
//    
//    private func updateTimeLabels() {
//        let current = Int(currentTime)
//        let remaining = Int(duration - currentTime)
//        currentTimeLabel.text = String(format: "%d:%02d", current / 60, current % 60)
//        remainingTimeLabel.text = String(format: "-%d:%02d", remaining / 60, remaining % 60)
//    }
//
//    // MARK: - Layout
//    private func setupConstraints(dismissIcon: UIButton) {
//        NSLayoutConstraint.activate([
//            // INCREASED TOP PADDING TO SHIFT EVERYTHING DOWN
//            dismissIcon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            dismissIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            
//            albumArtContainer.topAnchor.constraint(equalTo: dismissIcon.bottomAnchor, constant: 60),
//            albumArtContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            albumArtContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
//            albumArtContainer.heightAnchor.constraint(equalTo: albumArtContainer.widthAnchor),
//            
//            albumArt.topAnchor.constraint(equalTo: albumArtContainer.topAnchor),
//            albumArt.leadingAnchor.constraint(equalTo: albumArtContainer.leadingAnchor),
//            albumArt.trailingAnchor.constraint(equalTo: albumArtContainer.trailingAnchor),
//            albumArt.bottomAnchor.constraint(equalTo: albumArtContainer.bottomAnchor),
//            
//            transcriptBox.topAnchor.constraint(equalTo: dismissIcon.bottomAnchor, constant: 60),
//            transcriptBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
//            transcriptBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
//            transcriptBox.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -40),
//            
//            transcriptTextView.topAnchor.constraint(equalTo: transcriptBox.topAnchor),
//            transcriptTextView.leadingAnchor.constraint(equalTo: transcriptBox.leadingAnchor),
//            transcriptTextView.trailingAnchor.constraint(equalTo: transcriptBox.trailingAnchor),
//            transcriptTextView.bottomAnchor.constraint(equalTo: transcriptBox.bottomAnchor),
//            
//            titleLabel.topAnchor.constraint(equalTo: albumArtContainer.bottomAnchor, constant: 55),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
//            titleLabel.trailingAnchor.constraint(equalTo: moreBtn.leadingAnchor, constant: -10),
//            titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
//            
//            moreBtn.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
//            moreBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
//            moreBtn.widthAnchor.constraint(equalToConstant: 30),
//            moreBtn.heightAnchor.constraint(equalToConstant: 30),
//            
//            sourceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            sourceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            
//            currentTimeLabel.topAnchor.constraint(equalTo: sourceLabel.bottomAnchor, constant: 35),
//            currentTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
//            
//            remainingTimeLabel.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),
//            remainingTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
//            
//            playbackSlider.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 8),
//            playbackSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
//            playbackSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
//            
//            playPauseBtn.topAnchor.constraint(equalTo: playbackSlider.bottomAnchor, constant: 55),
//            playPauseBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            playPauseBtn.widthAnchor.constraint(equalToConstant: 60),
//            playPauseBtn.heightAnchor.constraint(equalToConstant: 60),
//            
//            backwardBtn.centerYAnchor.constraint(equalTo: playPauseBtn.centerYAnchor),
//            backwardBtn.trailingAnchor.constraint(equalTo: playPauseBtn.leadingAnchor, constant: -50),
//            
//            forwardBtn.centerYAnchor.constraint(equalTo: playPauseBtn.centerYAnchor),
//            forwardBtn.leadingAnchor.constraint(equalTo: playPauseBtn.trailingAnchor, constant: 50),
//            
//            // Re-centered the original single caption toggle icon
//            transcriptToggle.topAnchor.constraint(equalTo: playPauseBtn.bottomAnchor, constant: 50),
//            transcriptToggle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            transcriptToggle.widthAnchor.constraint(equalToConstant: 44),
//            transcriptToggle.heightAnchor.constraint(equalToConstant: 44),
//            transcriptToggle.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
//        ])
//    }
//    
//    deinit {
//        stopPlayback()
//        stopSpeech()
//        audioEngine.stop()
//        do { try audioSession?.setActive(false) } catch { }
//    }
//}
//
//// MARK: - AVSpeechSynthesizerDelegate
//extension NewAudioPlayerViewController: AVSpeechSynthesizerDelegate {
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        DispatchQueue.main.async { self.handleTrackEnd() }
//    }
//}
//
//// MARK: - UIGestureRecognizerDelegate
//extension NewAudioPlayerViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        if touch.view is UISlider {
//            return false
//        }
//        
//        if let view = touch.view, view.superview is UISlider {
//            return false
//        }
//        
//        return true
//    }
//}
