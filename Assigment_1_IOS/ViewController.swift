
//  ViewController.swift
//  Assigment_1_IOS

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
    private let mainStackView = UIStackView()
    private let globeStackView = UIView()
    private let globeContentSpacerView = UIView()
    private let centerStackView = UIStackView()
    private let westGlobeView = GlobeView(title: "West Side", color: .systemBlue)
    private let eastGlobeView = GlobeView(title: "East Side", color: .systemOrange)
    private var westGlobeWidthConstraint: NSLayoutConstraint?
    private var westGlobeHeightConstraint: NSLayoutConstraint?
    private var eastGlobeWidthConstraint: NSLayoutConstraint?
    private var eastGlobeHeightConstraint: NSLayoutConstraint?
    private var mainStackTopConstraint: NSLayoutConstraint?
    private var mainStackBottomConstraint: NSLayoutConstraint?
    private var mainStackCenterYConstraint: NSLayoutConstraint?
    private var globeContentSpacerHeightConstraint: NSLayoutConstraint?
    private var westGlobeLeadingConstraint: NSLayoutConstraint?
    private var eastGlobeTrailingConstraint: NSLayoutConstraint?
    private var westGlobeCenterXConstraint: NSLayoutConstraint?
    private var eastGlobeCenterXConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Card Game"
        view.backgroundColor = .systemBackground

        // Set up the main screen UI.
        setupViews()
        updateScreen()

        // Start location only after a name already exists.
        if userName == nil {
            statusLabel.text = "Tap Insert Name to begin."
        } else {
            beginLocationFlow()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Refresh adaptive layout after rotation or size changes.
        updateLayoutForCurrentSize()
    }

    // Build the main screen views and constraints.
    private func setupViews() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        greetingLabel.font = .systemFont(ofSize: 32, weight: .bold)
        greetingLabel.textAlignment = .center
        greetingLabel.numberOfLines = 0
        greetingLabel.textColor = .label

        sideLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        sideLabel.textAlignment = .center
        sideLabel.numberOfLines = 0
        sideLabel.textColor = .label

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
        startButton.isUserInteractionEnabled = true
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)

        globeStackView.addSubview(westGlobeView)
        globeStackView.addSubview(eastGlobeView)
        globeStackView.isUserInteractionEnabled = false
        globeStackView.translatesAutoresizingMaskIntoConstraints = false
        westGlobeView.translatesAutoresizingMaskIntoConstraints = false
        eastGlobeView.translatesAutoresizingMaskIntoConstraints = false
        globeContentSpacerView.isUserInteractionEnabled = false

        centerStackView.addArrangedSubview(statusLabel)
        centerStackView.addArrangedSubview(nameButton)
        centerStackView.addArrangedSubview(startButton)
        centerStackView.axis = .vertical
        centerStackView.alignment = .center
        centerStackView.spacing = 14
        centerStackView.translatesAutoresizingMaskIntoConstraints = false

        mainStackView.addArrangedSubview(greetingLabel)
        mainStackView.addArrangedSubview(globeStackView)
        mainStackView.addArrangedSubview(globeContentSpacerView)
        mainStackView.addArrangedSubview(centerStackView)
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.spacing = 16
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)

        westGlobeWidthConstraint = westGlobeView.widthAnchor.constraint(equalToConstant: 120)
        westGlobeHeightConstraint = westGlobeView.heightAnchor.constraint(equalToConstant: 150)
        eastGlobeWidthConstraint = eastGlobeView.widthAnchor.constraint(equalToConstant: 120)
        eastGlobeHeightConstraint = eastGlobeView.heightAnchor.constraint(equalToConstant: 150)
        mainStackTopConstraint = mainStackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 18)
        mainStackBottomConstraint = mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -18)
        mainStackCenterYConstraint = mainStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        globeContentSpacerHeightConstraint = globeContentSpacerView.heightAnchor.constraint(equalToConstant: 30)
        westGlobeLeadingConstraint = westGlobeView.leadingAnchor.constraint(equalTo: globeStackView.leadingAnchor, constant: 22)
        eastGlobeTrailingConstraint = eastGlobeView.trailingAnchor.constraint(equalTo: globeStackView.trailingAnchor, constant: -22)
        westGlobeCenterXConstraint = westGlobeView.centerXAnchor.constraint(equalTo: globeStackView.centerXAnchor)
        eastGlobeCenterXConstraint = eastGlobeView.centerXAnchor.constraint(equalTo: globeStackView.centerXAnchor)

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

            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainStackTopConstraint!,
            mainStackBottomConstraint!,
            mainStackCenterYConstraint!,
            globeStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            westGlobeView.topAnchor.constraint(equalTo: globeStackView.topAnchor),
            westGlobeView.bottomAnchor.constraint(equalTo: globeStackView.bottomAnchor),
            eastGlobeView.topAnchor.constraint(equalTo: globeStackView.topAnchor),
            eastGlobeView.bottomAnchor.constraint(equalTo: globeStackView.bottomAnchor),
            westGlobeLeadingConstraint!,
            eastGlobeTrailingConstraint!,
            globeContentSpacerView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            globeContentSpacerHeightConstraint!,
            centerStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            greetingLabel.widthAnchor.constraint(lessThanOrEqualTo: mainStackView.widthAnchor),
            statusLabel.widthAnchor.constraint(lessThanOrEqualTo: mainStackView.widthAnchor),
            westGlobeWidthConstraint!,
            westGlobeHeightConstraint!,
            eastGlobeWidthConstraint!,
            eastGlobeHeightConstraint!,
            nameButton.widthAnchor.constraint(equalToConstant: 190),
            nameButton.heightAnchor.constraint(equalToConstant: 52),
            startButton.widthAnchor.constraint(equalToConstant: 180),
            startButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    // Ask for location permission and start finding the player side.
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

    // Show the correct main screen state.
    private func updateScreen() {
        centerStackView.isHidden = false
        centerStackView.isUserInteractionEnabled = true

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
            sideLabel.isHidden = true
            westGlobeView.showsTitle = userSide == .west
            eastGlobeView.showsTitle = userSide == .east
            westGlobeView.isHidden = userSide != .west
            eastGlobeView.isHidden = userSide != .east
        } else {
            sideLabel.text = "Side: waiting for location"
            sideLabel.isHidden = userName == nil
            westGlobeView.showsTitle = true
            eastGlobeView.showsTitle = true
            westGlobeView.isHidden = false
            eastGlobeView.isHidden = false
        }

        let canStart = userName != nil && userSide != nil
        startButton.isHidden = !canStart
        startButton.isEnabled = canStart
        startButton.isUserInteractionEnabled = canStart
        updateLayoutForCurrentSize()
    }

    // Ask the user for a name and save it.
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

    // Decide if the player is on the east or west side.
    private func updateSide(from longitude: Double) {
        userSide = longitude > middleLongitude ? .east : .west
        updateScreen()
    }

    // Use a fixed location when real location is not available.
    private func useDefaultLocation() {
        locationManager.stopUpdatingLocation()
        updateSide(from: defaultSimulatorLongitude)
        statusLabel.text = "Using default simulator location."
    }

    @objc private func nameButtonTapped() {
        askForName()
    }

    // Navigate to the game screen.
    @objc private func startButtonTapped() {
        guard let userName, let userSide else {
            statusLabel.text = "Please enter your name and allow location first."
            return
        }

        if navigationController?.topViewController is GameViewController {
            return
        }

        guard let gameViewController = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else {
            return
        }

        gameViewController.userName = userName
        gameViewController.userSide = userSide
        navigationController?.pushViewController(gameViewController, animated: true)
    }

    // Continue location flow after the user answers the permission prompt.
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

    // Use the latest location update to set the player side.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            useDefaultLocation()
            return
        }

        manager.stopUpdatingLocation()
        updateSide(from: location.coordinate.longitude)
    }

    // Fall back when location lookup fails.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        useDefaultLocation()
    }

    // Update main screen spacing and globe layout for portrait and landscape.
    private func updateLayoutForCurrentSize() {
        let isLandscape = view.bounds.width > view.bounds.height
        let hasSelectedSide = userSide != nil
        let isLandscapeIntro = isLandscape && userName == nil && userSide == nil
        let safeHeight = view.safeAreaLayoutGuide.layoutFrame.height
        let safeWidth = view.safeAreaLayoutGuide.layoutFrame.width
        let globeRowHorizontalInset: CGFloat = 16
        var landscapeIntroGlobeGrowth: CGFloat = 0
        let landscapeIntroGapReduction: CGFloat = isLandscapeIntro ? 42 : 0

        mainStackTopConstraint?.constant = isLandscape ? 8 : 18
        mainStackBottomConstraint?.constant = isLandscape ? -8 : -18
        mainStackView.setCustomSpacing(isLandscape && hasSelectedSide ? 8 : (isLandscapeIntro ? 8 : mainStackView.spacing), after: globeStackView)
        mainStackView.setCustomSpacing(isLandscape && hasSelectedSide ? 4 : (isLandscapeIntro ? 4 : mainStackView.spacing), after: globeContentSpacerView)
        centerStackView.spacing = isLandscape && hasSelectedSide ? 2 : (isLandscape ? 7 : 14)

        if hasSelectedSide {
            let selectedGlobeSize = isLandscape
                ? min(max(safeHeight * 0.34, 112), 150)
                : min(max(safeHeight * 0.22, 145), 195)
            westGlobeWidthConstraint?.constant = selectedGlobeSize
            westGlobeHeightConstraint?.constant = selectedGlobeSize + 34
            eastGlobeWidthConstraint?.constant = selectedGlobeSize
            eastGlobeHeightConstraint?.constant = selectedGlobeSize + 34
            westGlobeView.centersVisibleHalf = userSide == .west
            eastGlobeView.centersVisibleHalf = userSide == .east
            westGlobeLeadingConstraint?.isActive = false
            eastGlobeTrailingConstraint?.isActive = false
            westGlobeCenterXConstraint?.isActive = userSide == .west
            eastGlobeCenterXConstraint?.isActive = userSide == .east
        } else {
            let availableGlobeRowWidth = max(0, safeWidth - 16 - (globeRowHorizontalInset * 2))
            let targetMiddleGap: CGFloat = isLandscape ? (isLandscapeIntro ? 220 : 260) : 28
            let maxGlobeWidth = max(96, (availableGlobeRowWidth - targetMiddleGap) / 2)
            let baseLandscapeGlobeDiameter = min(max(safeHeight * 0.40, 124), min(170, maxGlobeWidth))
            let globeDiameter = isLandscape
                ? (isLandscapeIntro ? min(max(safeHeight * 0.49, 154), min(200, maxGlobeWidth)) : baseLandscapeGlobeDiameter)
                : min(max(safeHeight * 0.27, 165), min(220, maxGlobeWidth))
            let globeHeight = globeDiameter + 34
            landscapeIntroGlobeGrowth = isLandscapeIntro ? max(0, globeDiameter - baseLandscapeGlobeDiameter) : 0

            westGlobeWidthConstraint?.constant = globeDiameter
            westGlobeHeightConstraint?.constant = globeHeight
            eastGlobeWidthConstraint?.constant = globeDiameter
            eastGlobeHeightConstraint?.constant = globeHeight
            westGlobeView.centersVisibleHalf = false
            eastGlobeView.centersVisibleHalf = false
            westGlobeLeadingConstraint?.constant = globeRowHorizontalInset
            eastGlobeTrailingConstraint?.constant = -globeRowHorizontalInset
            westGlobeCenterXConstraint?.isActive = false
            eastGlobeCenterXConstraint?.isActive = false
            westGlobeLeadingConstraint?.isActive = true
            eastGlobeTrailingConstraint?.isActive = true
        }

        mainStackCenterYConstraint?.constant = isLandscape && hasSelectedSide ? -34 : (isLandscapeIntro ? -((landscapeIntroGlobeGrowth + landscapeIntroGapReduction) / 2) : 0)

        let defaultSpacerHeight: CGFloat = isLandscape ? 30 : 48
        if !isLandscape && userName == nil && userSide == nil {
            let bottomSafeMargin: CGFloat = 70
            let desiredStackHeight = max(0, safeHeight - (bottomSafeMargin * 2))
            let globeHeight = westGlobeHeightConstraint?.constant ?? globeStackView.bounds.height
            let centerHeight = centerStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            let minimumSpacerHeight: CGFloat = 72
            let maximumSpacerHeight = max(minimumSpacerHeight, safeHeight * 0.34)
            let spacerHeight = min(
                max(desiredStackHeight - globeHeight - centerHeight, minimumSpacerHeight),
                maximumSpacerHeight
            )

            globeContentSpacerHeightConstraint?.constant = spacerHeight
        } else if isLandscape && hasSelectedSide {
            globeContentSpacerHeightConstraint?.constant = 0
        } else if isLandscapeIntro {
            globeContentSpacerHeightConstraint?.constant = 8
        } else {
            globeContentSpacerHeightConstraint?.constant = defaultSpacerHeight
        }
    }
}

// Draws the half-globe icons and their side labels.
class GlobeView: UIView {
    private let title: String
    private let color: UIColor
    private let titleLabel = UILabel()
    var centersVisibleHalf = false {
        didSet {
            titleLabel.textAlignment = titleAlignment()
            titleLabel.textColor = currentTitleColor()
            setNeedsDisplay()
        }
    }
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
        let isEastSide = title.hasPrefix("East")
        let globeX: CGFloat
        if centersVisibleHalf {
            globeX = isEastSide ? (bounds.width / 2) - (globeSize * 0.75) : (bounds.width / 2) - (globeSize * 0.25)
        } else {
            globeX = isEastSide ? bounds.width - globeSize : 0
        }
        let globeRect = CGRect(
            x: globeX,
            y: 0,
            width: globeSize,
            height: globeSize
        ).insetBy(dx: 4, dy: 4)
        let clipRect = isEastSide
            ? CGRect(x: globeRect.midX, y: globeRect.minY, width: globeRect.width / 2, height: globeRect.height)
            : CGRect(x: globeRect.minX, y: globeRect.minY, width: globeRect.width / 2, height: globeRect.height)

        let drawingColor = currentDrawingColor()
        drawingColor.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.28 : 0.14).setFill()
        drawingColor.setStroke()

        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.clip(to: clipRect)

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

        context.restoreGState()
    }

    private func setupViews() {
        backgroundColor = .clear
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = titleAlignment()
        titleLabel.textColor = currentTitleColor()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (globeView: GlobeView, _) in
            globeView.titleLabel.textColor = globeView.currentTitleColor()
            globeView.setNeedsDisplay()
        }
    }

    private func currentDrawingColor() -> UIColor {
        if traitCollection.userInterfaceStyle == .dark {
            return title.hasPrefix("East") ? .darkGray : .gray
        }

        return color
    }

    private func currentTitleColor() -> UIColor {
        if centersVisibleHalf && traitCollection.userInterfaceStyle == .dark {
            return .label
        }

        return currentDrawingColor()
    }

    private func titleAlignment() -> NSTextAlignment {
        if centersVisibleHalf {
            return .center
        }

        return title.hasPrefix("East") ? .right : .left
    }
}
