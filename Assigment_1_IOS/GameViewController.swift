//
//  GameViewController.swift
//  Assigment_1_IOS
//
//  Created by Codex on 07/06/2026.
//

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

    private let roundLabel = UILabel()
    private let scoreLabel = UILabel()
    private let timerLabel = UILabel()
    private let playersStackView = UIStackView()
    private let userAreaView = UIView()
    private let pcAreaView = UIView()
    private let userCardView = CardView()
    private let pcCardView = CardView()

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
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if currentRound == 0 {
            startGame()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    private func setupViews() {
        roundLabel.font = .systemFont(ofSize: 22, weight: .bold)
        roundLabel.textAlignment = .center

        scoreLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        scoreLabel.textAlignment = .center
        scoreLabel.numberOfLines = 0

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

        setupPlayerArea(userAreaView, title: "\(userName)\n\(userSide.rawValue)", cardView: userCardView)
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

        let mainStackView = UIStackView(arrangedSubviews: [
            roundLabel,
            scoreLabel,
            timerStackView,
            playersStackView
        ])
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.spacing = 24
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            roundLabel.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            scoreLabel.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            timerImageView.widthAnchor.constraint(equalToConstant: 32),
            timerImageView.heightAnchor.constraint(equalToConstant: 32),
            playersStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            playersStackView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }

    private func setupPlayerArea(_ areaView: UIView, title: String, cardView: CardView) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        cardView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [titleLabel, cardView])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        areaView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: areaView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: areaView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: areaView.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 50),
            cardView.widthAnchor.constraint(equalTo: areaView.widthAnchor, multiplier: 0.9),
            cardView.heightAnchor.constraint(equalToConstant: 190)
        ])
    }

    private func startGame() {
        timer?.invalidate()
        userScore = 0
        pcScore = 0
        currentRound = 1
        startRound()
    }

    private func startRound() {
        countdown = 3
        dealCardsForCurrentRound()
        updateLabels()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.countdown -= 1

            if self.countdown == 0 {
                timer.invalidate()
                self.finishRound()
            } else {
                self.updateLabels()
            }
        }
    }

    private func finishRound() {
        compareCurrentCards()
        updateLabels()

        if currentRound == totalRounds {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showSummary()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.currentRound += 1
                self.startRound()
            }
        }
    }

    private func dealCardsForCurrentRound() {
        guard let userCard = deck.randomElement(), let pcCard = deck.randomElement() else {
            return
        }

        currentUserCard = userCard
        currentPcCard = pcCard
        userCardView.show(card: userCard)
        pcCardView.show(card: pcCard)
    }

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

    private func updateLabels() {
        roundLabel.text = "Round \(currentRound) of \(totalRounds)"
        scoreLabel.text = "\(userName): \(userScore)    PC: \(pcScore)"
        timerLabel.text = "\(countdown)"
    }

    private func showSummary() {
        timer?.invalidate()

        guard let summaryViewController = storyboard?.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController else {
            return
        }

        summaryViewController.userName = userName
        summaryViewController.userScore = userScore
        summaryViewController.pcScore = pcScore
        navigationController?.pushViewController(summaryViewController, animated: true)
    }
}

class CardView: UIView {
    private let rankLabel = UILabel()
    private let suitLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.label.cgColor

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

    func show(card: PlayingCard) {
        let updateCard = {
            self.rankLabel.text = card.rank
            self.suitLabel.text = card.suit
            self.suitLabel.textColor = card.suit == "♥" || card.suit == "♦" ? .systemRed : .label
            self.rankLabel.textColor = self.suitLabel.textColor
        }

        UIView.transition(with: self, duration: 0.35, options: .transitionFlipFromLeft, animations: updateCard)
    }
}
