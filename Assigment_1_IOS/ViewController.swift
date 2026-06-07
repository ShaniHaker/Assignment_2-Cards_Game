//
//  ViewController.swift
//  Assigment_1_IOS
//
//  Created by Shani Haker on 07/06/2026.
//

import UIKit
import CoreLocation

enum PlayerSide: String {
    case east = "East Side"
    case west = "West Side"
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    private let middleLongitude = 34.817549168324334
    private let defaultSimulatorLongitude = 34.7818
    private let nameKey = "savedUserName"

    private let locationManager = CLLocationManager()
    private var userSide: PlayerSide?
    private var didStartLocationFlow = false
    private var userName: String? {
        UserDefaults.standard.string(forKey: nameKey)
    }

    private let greetingLabel = UILabel()
    private let sideLabel = UILabel()
    private let statusLabel = UILabel()
    private let nameButton = UIButton(type: .system)
    private let startButton = UIButton(type: .system)
    private let westGlobeView = GlobeView(title: "West", color: .systemBlue)
    private let eastGlobeView = GlobeView(title: "East", color: .systemOrange)
    private var westGlobeHeightConstraint: NSLayoutConstraint?
    private var eastGlobeHeightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Card Game"
        view.backgroundColor = .systemBackground

        setupViews()
        updateScreen()

        if userName == nil {
            statusLabel.text = "Tap Insert Name to begin."
        } else {
            beginLocationFlow()
        }
    }

    private func setupViews() {
        greetingLabel.font = .systemFont(ofSize: 32, weight: .bold)
        greetingLabel.textAlignment = .center
        greetingLabel.numberOfLines = 0

        sideLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        sideLabel.textAlignment = .center
        sideLabel.numberOfLines = 0

        statusLabel.font = .systemFont(ofSize: 16)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        nameButton.setTitle("Insert Name", for: .normal)
        nameButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        nameButton.backgroundColor = .systemBlue
        nameButton.tintColor = .white
        nameButton.layer.cornerRadius = 12
        nameButton.addTarget(self, action: #selector(nameButtonTapped), for: .touchUpInside)

        startButton.setTitle("START", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        startButton.backgroundColor = .systemGreen
        startButton.tintColor = .white
        startButton.layer.cornerRadius = 12
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)

        let globeStackView = UIStackView(arrangedSubviews: [westGlobeView, eastGlobeView])
        globeStackView.axis = .horizontal
        globeStackView.alignment = .center
        globeStackView.distribution = .equalSpacing
        globeStackView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [
            globeStackView,
            greetingLabel,
            sideLabel,
            statusLabel,
            nameButton,
            startButton
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 22
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        westGlobeHeightConstraint = westGlobeView.heightAnchor.constraint(equalToConstant: 150)
        eastGlobeHeightConstraint = eastGlobeView.heightAnchor.constraint(equalToConstant: 150)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            globeStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            westGlobeView.widthAnchor.constraint(equalToConstant: 120),
            westGlobeHeightConstraint!,
            eastGlobeView.widthAnchor.constraint(equalToConstant: 120),
            eastGlobeHeightConstraint!,
            nameButton.widthAnchor.constraint(equalToConstant: 190),
            nameButton.heightAnchor.constraint(equalToConstant: 52),
            startButton.widthAnchor.constraint(equalToConstant: 180),
            startButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func beginLocationFlow() {
        guard !didStartLocationFlow else { return }

        didStartLocationFlow = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        switch locationManager.authorizationStatus {
        case .notDetermined:
            statusLabel.text = "Location is needed before the game can start."
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            statusLabel.text = "Finding your side..."
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            useDefaultLocation()
        @unknown default:
            useDefaultLocation()
        }
    }

    private func updateScreen() {
        if let userName {
            greetingLabel.text = "Hi \(userName)"
            greetingLabel.isHidden = false
            nameButton.isHidden = true
        } else {
            greetingLabel.text = ""
            greetingLabel.isHidden = true
            nameButton.isHidden = false
        }

        if let userSide {
            sideLabel.text = userSide.rawValue
            statusLabel.text = "Ready to play."
            sideLabel.isHidden = false
            westGlobeHeightConstraint?.constant = 120
            eastGlobeHeightConstraint?.constant = 120
            westGlobeView.showsTitle = false
            eastGlobeView.showsTitle = false
            westGlobeView.isHidden = userSide != .west
            eastGlobeView.isHidden = userSide != .east
        } else {
            sideLabel.text = "Side: waiting for location"
            sideLabel.isHidden = userName == nil
            westGlobeHeightConstraint?.constant = 150
            eastGlobeHeightConstraint?.constant = 150
            westGlobeView.showsTitle = true
            eastGlobeView.showsTitle = true
            westGlobeView.isHidden = false
            eastGlobeView.isHidden = false
        }

        let canStart = userName != nil && userSide != nil
        startButton.isHidden = !canStart
        startButton.isEnabled = canStart
    }

    private func askForName() {
        let alert = UIAlertController(title: "Enter your name", message: "Your name is saved for later launches.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
        }

        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self else { return }
            let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            if text.isEmpty {
                self.askForName()
                return
            }

            UserDefaults.standard.set(text, forKey: self.nameKey)
            self.updateScreen()
            self.beginLocationFlow()
        })

        present(alert, animated: true)
    }

    private func updateSide(from longitude: Double) {
        userSide = longitude > middleLongitude ? .east : .west
        updateScreen()
    }

    private func useDefaultLocation() {
        locationManager.stopUpdatingLocation()
        updateSide(from: defaultSimulatorLongitude)
        statusLabel.text = "Using default simulator location."
    }

    @objc private func nameButtonTapped() {
        askForName()
    }

    @objc private func startButtonTapped() {
        guard let userName, let userSide else {
            statusLabel.text = "Please enter your name and allow location first."
            return
        }

        guard let gameViewController = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else {
            return
        }

        gameViewController.userName = userName
        gameViewController.userSide = userSide
        navigationController?.pushViewController(gameViewController, animated: true)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            statusLabel.text = "Finding your side..."
            manager.startUpdatingLocation()
        case .denied, .restricted:
            useDefaultLocation()
        case .notDetermined:
            break
        @unknown default:
            useDefaultLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            useDefaultLocation()
            return
        }

        manager.stopUpdatingLocation()
        updateSide(from: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        useDefaultLocation()
    }
}

class GlobeView: UIView {
    private let title: String
    private let color: UIColor
    private let titleLabel = UILabel()
    var showsTitle = true {
        didSet {
            titleLabel.isHidden = !showsTitle
            setNeedsDisplay()
        }
    }

    init(title: String, color: UIColor) {
        self.title = title
        self.color = color
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        self.title = ""
        self.color = .systemBlue
        super.init(coder: coder)
        setupViews()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let titleSpace: CGFloat = showsTitle ? 34 : 0
        let globeSize = min(bounds.width, bounds.height - titleSpace)
        let globeRect = CGRect(
            x: (bounds.width - globeSize) / 2,
            y: 0,
            width: globeSize,
            height: globeSize
        ).insetBy(dx: 4, dy: 4)

        color.withAlphaComponent(0.14).setFill()
        color.setStroke()

        let circlePath = UIBezierPath(ovalIn: globeRect)
        circlePath.lineWidth = 3
        circlePath.fill()
        circlePath.stroke()

        let centerY = globeRect.midY
        let horizontalPath = UIBezierPath()
        horizontalPath.move(to: CGPoint(x: globeRect.minX + 8, y: centerY))
        horizontalPath.addLine(to: CGPoint(x: globeRect.maxX - 8, y: centerY))
        horizontalPath.lineWidth = 2
        horizontalPath.stroke()

        for offset in [-0.25, 0.25] {
            let y = centerY + globeRect.height * offset
            let path = UIBezierPath()
            path.move(to: CGPoint(x: globeRect.minX + 16, y: y))
            path.addQuadCurve(
                to: CGPoint(x: globeRect.maxX - 16, y: y),
                controlPoint: CGPoint(x: globeRect.midX, y: y + globeRect.height * offset * 0.35)
            )
            path.lineWidth = 1.5
            path.stroke()
        }

        for multiplier in [-0.28, 0.28] {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: globeRect.midX, y: globeRect.minY + 4))
            path.addQuadCurve(
                to: CGPoint(x: globeRect.midX, y: globeRect.maxY - 4),
                controlPoint: CGPoint(x: globeRect.midX + globeRect.width * multiplier, y: globeRect.midY)
            )
            path.lineWidth = 1.5
            path.stroke()
        }
    }

    private func setupViews() {
        backgroundColor = .clear
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = color
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
