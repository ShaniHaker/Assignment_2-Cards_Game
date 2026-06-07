//
//  SummaryViewController.swift
//  Assigment_1_IOS
//
//  Created by Codex on 07/06/2026.
//

import UIKit

class SummaryViewController: UIViewController {
    var userName = "User"
    var userScore = 0
    var pcScore = 0

    private let winnerLabel = UILabel()
    private let scoreLabel = UILabel()
    private let backButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Summary"
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        setupViews()
        updateLabels()
    }

    private func setupViews() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        winnerLabel.font = .systemFont(ofSize: 30, weight: .bold)
        winnerLabel.textAlignment = .center
        winnerLabel.numberOfLines = 0
        winnerLabel.textColor = .label

        scoreLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        scoreLabel.textAlignment = .center
        scoreLabel.numberOfLines = 0
        scoreLabel.textColor = .label

        backButton.setTitle("BACK TO MENU", for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        backButton.backgroundColor = .systemBlue
        backButton.tintColor = .white
        backButton.layer.cornerRadius = 12
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [winnerLabel, scoreLabel, backButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 28
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

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

            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 24),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 220),
            backButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func updateLabels() {
        let userWins = userScore >= pcScore
        let winner = userWins ? userName : "PC"
        let winnerScore = userWins ? userScore : pcScore
        winnerLabel.text = "Winner: \(winner)"
        scoreLabel.text = "Score: \(winnerScore)"
    }

    @objc private func backButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
