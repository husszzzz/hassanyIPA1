import UIKit

private enum HassanyStyle {
    static let background = UIColor(red: 0.025, green: 0.026, blue: 0.075, alpha: 1)
    static let card = UIColor(red: 0.064, green: 0.058, blue: 0.13, alpha: 0.97)
    static let violet = UIColor(red: 0.63, green: 0.39, blue: 1, alpha: 1)
    static let cyan = UIColor(red: 0.30, green: 0.74, blue: 1, alpha: 1)
    static let muted = UIColor(red: 0.71, green: 0.70, blue: 0.82, alpha: 1)
}

@objc(HassanyBridge)
public final class HassanyBridge: NSObject {
    @objc(presentOn:)
    public static func present(on presenter: UIViewController) {
        guard presenter.presentedViewController == nil else { return }
        let welcome = HassanyWelcomeController()
        welcome.modalPresentationStyle = .overFullScreen
        presenter.present(welcome, animated: true)
    }
}

// Native UIKit and Swift, no HTML, WebView or remote UI.
private final class HassanyWelcomeController: UIViewController, UITextFieldDelegate {
    private let gradient = CAGradientLayer()
    private let scroll = UIScrollView()
    private let card = UIView()
    private let columns = UIStackView()
    private let hero = UIStackView()
    private let form = UIStackView()
    private let badge = UILabel()
    private let headline = UILabel()
    private let subtitle = UILabel()
    private let byline = UILabel()
    private let formTitle = UILabel()
    private let formDescription = UILabel()
    private let status = UILabel()
    private let credit = UILabel()
    private let codeField = UITextField()
    private let verifyButton = UIButton(type: .system)
    private let enterButton = UIButton(type: .system)
    private let developerButton = UIButton(type: .system)
    private let channelButton = UIButton(type: .system)
    private let languageButton = UIButton(type: .system)
    private let logoView = UIImageView()
    private var landscapeWidth: NSLayoutConstraint?
    private var isLandscapeLayout = false
    private var isArabic = true
    private var verified = false
    private var maintenanceActive = false
    private var needsUpdate = false

    private var apiRoot: String {
        (Bundle.main.object(forInfoDictionaryKey: "HassanyAPIBaseURL") as? String)
            ?? "https://backend-black-delta-89.vercel.app"
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = HassanyStyle.background
        gradient.colors = [
            UIColor(red: 0.04, green: 0.02, blue: 0.10, alpha: 1).cgColor,
            UIColor(red: 0.17, green: 0.08, blue: 0.32, alpha: 1).cgColor,
            UIColor(red: 0.035, green: 0.09, blue: 0.19, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .onDrag
        view.addSubview(scroll)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = HassanyStyle.card
        card.layer.cornerRadius = 24
        card.layer.borderWidth = 1
        card.layer.borderColor = HassanyStyle.violet.withAlphaComponent(0.32).cgColor
        card.layer.shadowColor = HassanyStyle.violet.cgColor
        card.layer.shadowOpacity = 0.2
        card.layer.shadowRadius = 28
        card.layer.shadowOffset = CGSize(width: 0, height: 10)
        scroll.addSubview(card)

        columns.translatesAutoresizingMaskIntoConstraints = false
        columns.spacing = 23
        columns.alignment = .center
        columns.distribution = .fill
        card.addSubview(columns)
        [hero, form].forEach {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.spacing = 10
            columns.addArrangedSubview($0)
        }

        let fillWidth = card.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -24)
        fillWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            card.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 9),
            card.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -9),
            card.centerXAnchor.constraint(equalTo: scroll.frameLayoutGuide.centerXAnchor),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 890),
            card.widthAnchor.constraint(lessThanOrEqualTo: scroll.frameLayoutGuide.widthAnchor, constant: -24),
            fillWidth,
            columns.topAnchor.constraint(equalTo: card.topAnchor, constant: 19),
            columns.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -19),
            columns.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 21),
            columns.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -21)
        ])

        logoView.contentMode = .scaleAspectFit
        logoView.image = UIImage(named: "HassanyWelcomeLogo")
        logoView.heightAnchor.constraint(equalToConstant: 105).isActive = true
        hero.addArrangedSubview(logoView)
        setupLabel(badge, size: 10, weight: .bold, color: HassanyStyle.violet)
        setupLabel(headline, size: 31, weight: .heavy, color: .white)
        setupLabel(subtitle, size: 15, weight: .medium, color: HassanyStyle.muted)
        setupLabel(byline, size: 12, weight: .medium, color: HassanyStyle.muted)
        [badge, headline, subtitle, byline].forEach { hero.addArrangedSubview($0) }

        let bar = UIView()
        bar.backgroundColor = HassanyStyle.violet.withAlphaComponent(0.6)
        bar.heightAnchor.constraint(equalToConstant: 2).isActive = true
        hero.addArrangedSubview(bar)
        setupLabel(credit, size: 10, weight: .regular, color: HassanyStyle.muted)
        hero.addArrangedSubview(credit)

        setupLabel(formTitle, size: 19, weight: .bold, color: .white)
        setupLabel(formDescription, size: 12, weight: .medium, color: HassanyStyle.muted)
        [formTitle, formDescription].forEach { form.addArrangedSubview($0) }
        codeField.heightAnchor.constraint(equalToConstant: 46).isActive = true
        codeField.textColor = .white
        codeField.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        codeField.layer.cornerRadius = 12
        codeField.layer.borderColor = HassanyStyle.violet.withAlphaComponent(0.45).cgColor
        codeField.layer.borderWidth = 1
        codeField.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        codeField.textAlignment = .center
        codeField.autocorrectionType = .no
        codeField.autocapitalizationType = .allCharacters
        codeField.returnKeyType = .done
        codeField.delegate = self
        form.addArrangedSubview(codeField)

        button(verifyButton, highlighted: true, action: #selector(verify))
        form.addArrangedSubview(verifyButton)
        setupLabel(status, size: 12, weight: .medium, color: HassanyStyle.muted)
        form.addArrangedSubview(status)
        button(enterButton, highlighted: true, action: #selector(enterGame))
        enterButton.isHidden = true
        form.addArrangedSubview(enterButton)
        button(developerButton, highlighted: false, action: #selector(openDeveloper))
        form.addArrangedSubview(developerButton)
        button(channelButton, highlighted: false, action: #selector(openChannel))
        form.addArrangedSubview(channelButton)
        button(languageButton, highlighted: false, action: #selector(switchLanguage))
        form.addArrangedSubview(languageButton)
        applyLanguage()
        fetchAppStatus()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
        let wide = view.bounds.width > view.bounds.height && view.bounds.width > 620
        if wide != isLandscapeLayout {
            isLandscapeLayout = wide
            landscapeWidth?.isActive = false
            columns.axis = wide ? .horizontal : .vertical
            columns.alignment = wide ? .center : .fill
            if wide {
                let constraint = hero.widthAnchor.constraint(equalTo: form.widthAnchor, multiplier: 0.93)
                constraint.isActive = true
                landscapeWidth = constraint
            }
        }
    }

    private func setupLabel(_ label: UILabel, size: CGFloat, weight: UIFont.Weight, color: UIColor) {
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.numberOfLines = 0
        label.textAlignment = .center
    }
    private func button(_ target: UIButton, highlighted: Bool, action: Selector) {
        target.backgroundColor = highlighted ? HassanyStyle.violet : UIColor.white.withAlphaComponent(0.085)
        target.layer.cornerRadius = 12
        target.layer.borderWidth = highlighted ? 0 : 1
        target.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        target.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        target.setTitleColor(.white, for: .normal)
        target.heightAnchor.constraint(equalToConstant: 42).isActive = true
        target.addTarget(self, action: action, for: .touchUpInside)
    }
    private func applyLanguage() {
        badge.text = "✦   H A S S A N Y   •   P R E M I U M"
        headline.text = "HASSANY IPA"
        subtitle.text = isArabic ? "تجربة بلياردو بهوية الحسني" : "A refined billiards experience"
        byline.text = isArabic ? "حسين الحسني  •  @om_g9" : "Hussein Al-Hassany  •  @om_g9"
        credit.text = "© HASSANY IPA  •  @hassanyIPA"
        formTitle.text = isArabic ? "تفعيل النسخة" : "Activate your access"
        formDescription.text = isArabic ? "أدخل الكود للتحقق من السيرفر" : "Enter your code to verify with the server"
        codeField.attributedPlaceholder = NSAttributedString(
            string: isArabic ? "كود HASSANY" : "Your HASSANY code",
            attributes: [.foregroundColor: HassanyStyle.muted]
        )
        verifyButton.setTitle(isArabic ? "تحقق من الكود  ◈" : "Verify code  ◈", for: .normal)
        enterButton.setTitle(isArabic ? "دخول اللعبة  ←" : "Enter game  →", for: .normal)
        developerButton.setTitle(isArabic ? "المطور  •  حسين الحسني" : "Developer  •  Hussein Al-Hassany", for: .normal)
        channelButton.setTitle(isArabic ? "القناة الرسمية  •  @hassanyIPA" : "Official channel  •  @hassanyIPA", for: .normal)
        languageButton.setTitle(isArabic ? "English  /  عربي" : "عربي  /  English", for: .normal)
        if !verified && !maintenanceActive && !needsUpdate {
            status.text = isArabic ? "جاهز للتحقق الآمن" : "Ready for secure verification"
        }
    }
    @objc private func switchLanguage() { isArabic.toggle(); applyLanguage() }
    @objc private func openDeveloper() {
        if let url = URL(string: "https://t.me/om_g9") { UIApplication.shared.open(url) }
    }
    @objc private func openChannel() {
        if let url = URL(string: "https://t.me/hassanyIPA") { UIApplication.shared.open(url) }
    }
    @objc private func enterGame() {
        guard verified && !maintenanceActive && !needsUpdate else { return }
        dismiss(animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        verify()
        return true
    }

    // Server response is authoritative for the activation decision shown by this UI.
    @objc private func verify() {
        codeField.resignFirstResponder()
        verified = false
        enterButton.isHidden = true
        guard !maintenanceActive && !needsUpdate else { return }
        let code = (codeField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard code.count >= 10 else {
            status.text = isArabic ? "رجاءً أدخل كوداً صالحاً" : "Please enter a valid code"
            return
        }
        guard apiRoot.hasPrefix("https://"), let url = URL(string: apiRoot + "/api/activate") else {
            status.text = "Server configuration error"
            return
        }
        let key = "HassanyClientDeviceID"
        let defaults = UserDefaults.standard
        var deviceID = defaults.string(forKey: key)
        if deviceID == nil { deviceID = UUID().uuidString; defaults.set(deviceID, forKey: key) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "code": code, "device_id": deviceID ?? ""
        ])
        verifyButton.isEnabled = false
        status.textColor = HassanyStyle.muted
        status.text = isArabic ? "جاري التحقق..." : "Checking code..."
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            let answer = data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] } ?? [:]
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.verifyButton.isEnabled = true
                if answer["ok"] as? Bool == true && !self.maintenanceActive && !self.needsUpdate {
                    self.verified = true
                    self.enterButton.isHidden = false
                    self.status.textColor = .systemGreen
                    self.status.text = self.isArabic ? "الكود صحيح ✓ تگدر تدخل هسه" : "Valid code ✓ You can enter"
                } else {
                    self.verified = false
                    self.enterButton.isHidden = true
                    self.status.textColor = .systemOrange
                    let msg = answer["error"] as? String
                    if msg == "maintenance" {
                        self.maintenanceActive = true
                        self.status.text = self.isArabic ? "الخدمة تحت الصيانة" : "Service under maintenance"
                    } else {
                        self.status.text = error == nil
                            ? (self.isArabic ? "الكود غير صالح أو منتهي" : "Invalid or expired code")
                            : (self.isArabic ? "ما گدرنا نتصل بالسيرفر" : "Couldn't reach the server")
                    }
                }
            }
        }.resume()
    }

    private func fetchAppStatus() {
        guard let url = URL(string: apiRoot + "/api/status") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data,
                  let obj = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else { return }
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.maintenanceActive = (obj["maintenance"] as? Bool) ?? false
                let force = (obj["force_update"] as? Bool) ?? false
                let latest = (obj["latest_version"] as? String) ?? ""
                self.needsUpdate = force && latest.compare("4.0", options: .numeric) == .orderedDescending
                if self.maintenanceActive || self.needsUpdate {
                    self.verified = false
                    self.enterButton.isHidden = true
                    self.verifyButton.isEnabled = false
                    self.status.textColor = .systemOrange
                    self.status.text = self.maintenanceActive
                        ? ((obj["maintenance_message"] as? String) ?? "تحت الصيانة")
                        : (self.isArabic ? "يتوفر تحديث مطلوب" : "Required update available")
                }
            }
        }.resume()
    }
}
