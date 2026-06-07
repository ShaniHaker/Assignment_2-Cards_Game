
//  GameViewController.swift
//  Assigment_2_IOS

import UIKit

struct PlayingCard {
    let rank: String
    let suit: String
    let strength: Int
}

class GameViewController: UIViewController {
    var userName = "User"
    var userSide: PlayerSide = .west

    private let totalRounds = 10
    private var currentRound = 0
    private var userScore = 0
    private var pcScore = 0
    private var countdown = 3
    private var timer: Timer?
    private var currentUserCard: PlayingCard?
    private var currentPcCard: PlayingCard?
    private var pendingWorkItem: DispatchWorkItem?
    private var isPaused = false
    private var isWaitingToStartNextRound = false
    private var isWaitingToShowSummary = false
    private var didFinishGame = false

    private let roundLabel = UILabel()
    private let scoreLabel = UILabel()
    private let timerLabel = UILabel()
    private let mainStackView = UIStackView()
    private let playersStackView = UIStackView()
    private let userAreaView = UIView()
    private let pcAreaView = UIView()
    private let userCardView = CardView()
    private let pcCardView = CardView()
    private var playersStackHeightConstraint: NSLayoutConstraint?
    private var userCardWidthConstraint: NSLayoutConstraint?
    private var userCardHeightConstraint: NSLayoutConstraint?
    private var pcCardWidthConstraint: NSLayoutConstraint?
    private var pcCardHeightConstraint: NSLayoutConstraint?
    private var userTitleHeightConstraint: NSLayoutConstraint?
    private var pcTitleHeightConstraint: NSLayoutConstraint?
    private var playerAreaStackViews: [UIStackView] = []
    private let audioController = GameAudioController.shared

    private let deck: [PlayingCard] = {
        let ranks: [(String, Int)] = [
            ("A", 14), ("K", 13), ("Q", 12), ("J", 11),
            ("10", 10), ("9", 9), ("8", 8), ("7", 7),
            ("6", 6), ("5", 5), ("4", 4), ("3", 3), ("2", 2)
        ]
        let suits = ["♥", "♦", "♣", "♠"]

        return ranks.flatMap { rank in
            suits.map { suit in
                PlayingCard(rank: rank.0, suit: suit, strength: rank.1)
            }
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Game"
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        // Set up the game screen UI.
        setupViews()
        setupLifecycleNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Start or resume gameplay when the screen is visible.
        if currentRound == 0 {
            startGame()
        } else if isPaused && !didFinishGame {
            resumeGame()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop the timer when leaving the screen.
        pauseGame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keep cards readable after rotation or size changes.
        updateLayoutForCurrentSize()
    }

    deinit {
        // Clean up timers, delayed work, and music.
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
        pendingWorkItem?.cancel()
        audioController.stopMusic()
    }

    // Build the game screen labels, timer, player areas, and constraints.
    private func setupViews() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        roundLabel.font = .systemFont(ofSize: 22, weight: .bold)
        roundLabel.textAlignment = .center
        roundLabel.textColor = .label

        scoreLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        scoreLabel.textAlignment = .center
        scoreLabel.numberOfLines = 0
        scoreLabel.textColor = .label

        timerLabel.font = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        timerLabel.textAlignment = .center
        timerLabel.textColor = .systemBlue

        let timerImageView = UIImageView(image: UIImage(systemName: "timer"))
        timerImageView.tintColor = .systemBlue
        timerImageView.contentMode = .scaleAspectFit
        timerImageView.translatesAutoresizingMaskIntoConstraints = false

        let timerStackView = UIStackView(arrangedSubviews: [timerImageView, timerLabel])
        timerStackView.axis = .horizontal
        timerStackView.alignment = .center
        timerStackView.spacing = 8
        timerStackView.translatesAutoresizingMaskIntoConstraints = false

        setupPlayerArea(userAreaView, title: userName, cardView: userCardView)
        setupPlayerArea(pcAreaView, title: "PC", cardView: pcCardView)

        playersStackView.axis = .horizontal
        playersStackView.alignment = .fill
        playersStackView.distribution = .fillEqually
        playersStackView.spacing = 16

        if userSide == .west {
            playersStackView.addArrangedSubview(userAreaView)
            playersStackView.addArrangedSubview(pcAreaView)
        } else {
            playersStackView.addArrangedSubview(pcAreaView)
            playersStackView.addArrangedSubview(userAreaView)
        }

        mainStackView.addArrangedSubview(roundLabel)
        mainStackView.addArrangedSubview(scoreLabel)
        mainStackView.addArrangedSubview(timerStackView)
        mainStackView.addArrangedSubview(playersStackView)
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.spacing = 24
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)

        playersStackHeightConstraint = playersStackView.heightAnchor.constraint(equalToConstant: 300)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            mainStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            roundLabel.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            scoreLabel.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            timerImageView.widthAnchor.constraint(equalToConstant: 32),
            timerImageView.heightAnchor.constraint(equalToConstant: 32),
            playersStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            playersStackHeightConstraint!
        ])
    }

    // Set up one player name and card area.
    private func setupPlayerArea(_ areaView: UIView, title: String, cardView: CardView) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label

        cardView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [titleLabel, cardView])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        playerAreaStackViews.append(stackView)

        areaView.addSubview(stackView)

        let cardWidthConstraint = cardView.widthAnchor.constraint(equalToConstant: 130)
        let cardHeightConstraint = cardView.heightAnchor.constraint(equalToConstant: 190)
        let titleHeightConstraint = titleLabel.heightAnchor.constraint(equalToConstant: 30)
        if cardView === userCardView {
            userCardWidthConstraint = cardWidthConstraint
            userCardHeightConstraint = cardHeightConstraint
            userTitleHeightConstraint = titleHeightConstraint
        } else {
            pcCardWidthConstraint = cardWidthConstraint
            pcCardHeightConstraint = cardHeightConstraint
            pcTitleHeightConstraint = titleHeightConstraint
        }

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: areaView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: areaView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: areaView.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: areaView.bottomAnchor),
            titleHeightConstraint,
            cardWidthConstraint,
            cardHeightConstraint
        ])
    }

    // Starts a fresh game every time a new GameViewController is opened.
    private func startGame() {
        timer?.invalidate()
        pendingWorkItem?.cancel()
        didFinishGame = false
        isPaused = false
        isWaitingToStartNextRound = false
        isWaitingToShowSummary = false
        userScore = 0
        pcScore = 0
        currentRound = 1
        audioController.startMusic()
        startRound()
    }

    // Deals visible cards first; scoring happens only after the countdown reaches zero.
    private func startRound() {
        guard !didFinishGame else { return }

        countdown = 3
        isWaitingToStartNextRound = false
        dealCardsForCurrentRound()
        updateLabels()
        startCountdownTimer()
    }

    // Start the round countdown timer.
    private func startCountdownTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { return }
            guard !self.isPaused else {
                timer.invalidate()
                return
            }

            self.countdown -= 1

            if self.countdown == 0 {
                timer.invalidate()
                self.finishRound()
            } else {
                self.updateLabels()
            }
        }
    }

    // Compares the two currently displayed cards and schedules the next step.
    private func finishRound() {
        guard !didFinishGame else { return }

        compareCurrentCards()
        updateLabels()

        if currentRound == totalRounds {
            didFinishGame = true
            isWaitingToShowSummary = true
            audioController.stopMusic()
            audioController.playGameFinishedSound()
            scheduleAfterDelay(1.0) { [weak self] in
                self?.showSummary()
            }
        } else {
            isWaitingToStartNextRound = true
            scheduleAfterDelay(0.7) { [weak self] in
                self?.moveToNextRound()
            }
        }
    }

    // Pick random cards and show them on screen.
    private func dealCardsForCurrentRound() {
        guard let userCard = deck.randomElement(), let pcCard = deck.randomElement() else {
            return
        }

        currentUserCard = userCard
        currentPcCard = pcCard
        audioController.playCardSound()
        userCardView.show(card: userCard)
        pcCardView.show(card: pcCard)
    }

    // Add one point to the player with the stronger card.
    private func compareCurrentCards() {
        guard let userCard = currentUserCard, let pcCard = currentPcCard else {
            return
        }

        if userCard.strength > pcCard.strength {
            userScore += 1
        } else if pcCard.strength > userCard.strength {
            pcScore += 1
        }
    }

    // Update the round, score, and timer labels.
    private func updateLabels() {
        roundLabel.text = "Round \(currentRound) of \(totalRounds)"
        scoreLabel.text = "\(userName): \(userScore)    PC: \(pcScore)"
        timerLabel.text = "\(countdown)"
    }

    // Navigate to the summary screen.
    private func showSummary() {
        timer?.invalidate()
        pendingWorkItem?.cancel()
        audioController.stopMusic()
        isWaitingToShowSummary = false

        if navigationController?.topViewController is SummaryViewController {
            return
        }

        guard let summaryViewController = storyboard?.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController else {
            return
        }

        summaryViewController.userName = userName
        summaryViewController.userScore = userScore
        summaryViewController.pcScore = pcScore

        if var viewControllers = navigationController?.viewControllers {
            viewControllers.removeAll { $0 is SummaryViewController }
            viewControllers.append(summaryViewController)
            navigationController?.setViewControllers(viewControllers, animated: true)
        }
    }

    // Start the next game round.
    private func moveToNextRound() {
        guard !isPaused else { return }

        isWaitingToStartNextRound = false
        currentRound += 1
        startRound()
    }

    // Run delayed game actions safely.
    private func scheduleAfterDelay(_ delay: TimeInterval, action: @escaping () -> Void) {
        pendingWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self, !self.isPaused else { return }
            action()
        }

        pendingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    // Pauses gameplay state when the app backgrounds or this screen is no longer visible.
    private func pauseGame() {
        guard currentRound > 0 else {
            audioController.stopMusic()
            return
        }

        isPaused = true
        timer?.invalidate()
        pendingWorkItem?.cancel()
        if didFinishGame {
            audioController.stopMusic()
        } else {
            audioController.pauseMusic()
        }
    }

    // Resumes the exact pending state: countdown, next round delay, or final summary delay.
    private func resumeGame() {
        guard currentRound > 0 else { return }

        isPaused = false

        if isWaitingToShowSummary {
            showSummary()
        } else if isWaitingToStartNextRound {
            audioController.startMusic()
            moveToNextRound()
        } else if countdown > 0 {
            audioController.startMusic()
            updateLabels()
            startCountdownTimer()
        }
    }

    // Watch app background and foreground events.
    private func setupLifecycleNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc private func appDidEnterBackground() {
        pauseGame()
    }

    @objc private func appDidBecomeActive() {
        if navigationController?.topViewController === self {
            resumeGame()
        }
    }

    // Adjust card sizes and spacing for portrait and landscape.
    private func updateLayoutForCurrentSize() {
        let isLandscape = view.bounds.width > view.bounds.height
        let safeWidth = view.safeAreaLayoutGuide.layoutFrame.width
        let safeHeight = view.safeAreaLayoutGuide.layoutFrame.height

        mainStackView.spacing = isLandscape ? 4 : 24
        playersStackView.spacing = isLandscape ? 14 : 16
        playerAreaStackViews.forEach { $0.spacing = isLandscape ? 6 : 16 }

        if isLandscape {
            let titleHeight: CGFloat = 30
            let playerCardSpacing: CGFloat = 6
            let verticalMargins: CGFloat = 16
            let topContentHeight: CGFloat = 26 + 22 + 32 + (mainStackView.spacing * 3)
            let availableCardHeight = max(110, safeHeight - verticalMargins - topContentHeight - titleHeight - playerCardSpacing)

            let horizontalPadding: CGFloat = 72
            let maxCardWidth = max(80, (safeWidth - horizontalPadding - playersStackView.spacing) / 2)
            let maxCardHeightFromWidth = maxCardWidth * 1.5
            let cardHeight = min(availableCardHeight, maxCardHeightFromWidth, 190)
            let cardWidth = cardHeight * 2.0 / 3.0
            let playersHeight = titleHeight + playerCardSpacing + cardHeight

            userTitleHeightConstraint?.constant = titleHeight
            pcTitleHeightConstraint?.constant = titleHeight
            userCardWidthConstraint?.constant = cardWidth
            userCardHeightConstraint?.constant = cardHeight
            pcCardWidthConstraint?.constant = cardWidth
            pcCardHeightConstraint?.constant = cardHeight
            playersStackHeightConstraint?.constant = playersHeight
        } else {
            userTitleHeightConstraint?.constant = 30
            pcTitleHeightConstraint?.constant = 30
            userCardWidthConstraint?.constant = 130
            userCardHeightConstraint?.constant = 190
            pcCardWidthConstraint?.constant = 130
            pcCardHeightConstraint?.constant = 190
            playersStackHeightConstraint?.constant = 300
        }
    }
}

// Shows one playing card with rank and suit.
class CardView: UIView {
    private let rankLabel = UILabel()
    private let suitLabel = UILabel()
    private var currentSuit: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Keep card text readable when the card size changes.
        updateFontsForCurrentSize()
        updateColors()
    }

    // Build the card view UI.
    private func setupViews() {
        layer.cornerRadius = 16
        layer.borderWidth = 2
        updateColors()

        rankLabel.font = .systemFont(ofSize: 54, weight: .bold)
        rankLabel.textAlignment = .center

        suitLabel.font = .systemFont(ofSize: 48, weight: .bold)
        suitLabel.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [rankLabel, suitLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // Flip to the new card.
    func show(card: PlayingCard) {
        let updateCard = {
            self.currentSuit = card.suit
            self.rankLabel.text = card.rank
            self.suitLabel.text = card.suit
            self.updateColors()
        }

        UIView.transition(with: self, duration: 0.35, options: .transitionFlipFromLeft, animations: updateCard)
    }

    // Scale the rank and suit text with the card size.
    private func updateFontsForCurrentSize() {
        let rankSize = max(26, min(54, bounds.height * 0.28))
        let suitSize = max(24, min(48, bounds.height * 0.25))
        rankLabel.font = .systemFont(ofSize: rankSize, weight: .bold)
        suitLabel.font = .systemFont(ofSize: suitSize, weight: .bold)
    }

    // Use red for hearts and diamonds.
    private func updateColors() {
        backgroundColor = .secondarySystemBackground
        layer.borderColor = UIColor.label.cgColor

        let textColor: UIColor
        if currentSuit == "♥" || currentSuit == "♦" {
            textColor = .systemRed
        } else {
            textColor = .label
        }

        rankLabel.textColor = textColor
        suitLabel.textColor = textColor
    }
}
