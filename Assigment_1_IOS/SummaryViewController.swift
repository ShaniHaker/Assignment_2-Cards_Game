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
        winnerLabel.font = .systemFont(ofSize: 30, weight: .bold)
        winnerLabel.textAlignment = .center
        winnerLabel.numberOfLines = 0

        scoreLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        scoreLabel.textAlignment = .center
        scoreLabel.numberOfLines = 0

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

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
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
