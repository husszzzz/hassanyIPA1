import UIKit

private enum Theme {
    static let violet = UIColor(red: 0.55, green: 0.34, blue: 0.99, alpha: 1)
    static let blue = UIColor(red: 0.18, green: 0.62, blue: 1, alpha: 1)
    static let muted = UIColor(red: 0.75, green: 0.75, blue: 0.86, alpha: 1)
    static let panel = UIColor(red: 0.071, green: 0.065, blue: 0.14, alpha: 0.96)
}

@objc(HassanyBridge)
public final class HassanyBridge: NSObject {
    @objc(presentOn:)
    public static func present(on presenter: UIViewController) {
        guard presenter.presentedViewController == nil else { return }
        let vc = HassanyWelcomeController()
        vc.modalPresentationStyle = .overFullScreen
        presenter.present(vc, animated: true)
    }
}

private final class HassanyWelcomeController: UIViewController, UITextFieldDelegate {
    private let backdrop = CAGradientLayer()
    private let scroll = UIScrollView()
    private let panel = UIView()
    private let field = UITextField()
    private let status = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let activate = UIButton(type: .system)
    private let stack = UIStackView()
    private let enter = UIButton(type: .system)
    private var verified = false
    private var arabic = true

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        backdrop.colors = [
            UIColor(red: 0.025, green: 0.025, blue: 0.085, alpha: 1).cgColor,
            UIColor(red: 0.18, green: 0.075, blue: 0.36, alpha: 1).cgColor,
            UIColor(red: 0.025, green: 0.08, blue: 0.20, alpha: 1).cgColor
        ]
        backdrop.startPoint = CGPoint(x: 0, y: 0)
        backdrop.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backdrop, at: 0)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .interactive
        view.addSubview(scroll)

        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.backgroundColor = Theme.panel
        panel.layer.cornerRadius = 23
        panel.layer.borderWidth = 1
        panel.layer.borderColor = Theme.violet.withAlphaComponent(0.45).cgColor
        panel.layer.shadowColor = Theme.violet.cgColor
        panel.layer.shadowOpacity = 0.35
        panel.layer.shadowRadius = 22
        panel.layer.shadowOffset = CGSize(width: 0, height: 9)
        scroll.addSubview(panel)

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        panel.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            panel.centerXAnchor.constraint(equalTo: scroll.frameLayoutGuide.centerXAnchor),
            panel.widthAnchor.constraint(lessThanOrEqualToConstant: 540),
            panel.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, multiplier: 0.92),
            panel.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 12),
            panel.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: panel.topAnchor, constant: 19),
            stack.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 23),
            stack.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -23),
            stack.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -19)
        ])

        if let logo = UIImage(named: "HassanyWelcomeLogo") {
            let image = UIImageView(image: logo)
            image.contentMode = .scaleAspectFit
            image.heightAnchor.constraint(equalToConstant: 94).isActive = true
            stack.addArrangedSubview(image)
        }
        addLabel("✦   H A S S A N Y   P R E M I U M   ✦", size: 10, weight: .bold, color: Theme.violet)
        addLabel("HASSANY IPA", size: 32, weight: .heavy, color: .white)
        addLabel("أهلاً وسهلاً بك بعالم البلياردو", size: 15, weight: .medium, color: Theme.muted)
        addLabel("حسين الحسني • @om_g9 • @hassanyIPA", size: 12, weight: .medium, color: Theme.muted)
        let rule = UIView()
        rule.backgroundColor = .white.withAlphaComponent(0.12)
        rule.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stack.addArrangedSubview(rule)

        field.placeholder = "HASSANY-XXXXXX-XXXXXX-XXXXXX"
        field.textColor = .white
        field.attributedPlaceholder = NSAttributedString(string: "أدخل كود التفعيل",
                                                          attributes: [.foregroundColor: Theme.muted])
        field.font = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        field.textAlignment = .center
        field.backgroundColor = .white.withAlphaComponent(0.10)
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        field.layer.borderWidth = 1
        field.autocorrectionType = .no
        field.autocapitalizationType = .allCharacters
        field.delegate = self
        field.heightAnchor.constraint(equalToConstant: 46).isActive = true
        stack.addArrangedSubview(field)

        activate.setTitle("تفعيل الكود  ✦", for: .normal)
        style(activate, primary: true)
        activate.addTarget(self, action: #selector(verify), for: .touchUpInside)
        stack.addArrangedSubview(activate)

        status.numberOfLines = 2
        status.textAlignment = .center
        status.font = .systemFont(ofSize: 11, weight: .medium)
        status.textColor = Theme.muted
        status.text = "جاهز للتحقق عند ربط خادم الأكواد"
        stack.addArrangedSubview(status)

        let telegram = UIButton(type: .system)
        telegram.setTitle("✈   قناة Hassany IPA", for: .normal)
        style(telegram, primary: false)
        telegram.addTarget(self, action: #selector(openChannel), for: .touchUpInside)
        stack.addArrangedSubview(telegram)

        enter.setTitle("دخول اللعبة ←", for: .normal)
        style(enter, primary: false)
        enter.addTarget(self, action: #selector(continueGame), for: .touchUpInside)
        enter.isHidden = true
        stack.addArrangedSubview(enter)
        let developer = UIButton(type: .system)
        developer.setTitle("المطور • حسين الحسني", for: .normal)
        style(developer, primary: false)
        developer.addTarget(self, action: #selector(openDeveloper), for: .touchUpInside)
        stack.addArrangedSubview(developer)
        let language = UIButton(type: .system)
        language.setTitle("English / عربي", for: .normal)
        style(language, primary: false)
        language.addTarget(self, action: #selector(changeLanguage), for: .touchUpInside)
        stack.addArrangedSubview(language)

        addLabel("HASSANY IPA  •  © 2026  •  @OM_G9", size: 10, weight: .medium, color: Theme.muted)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backdrop.frame = view.bounds
    }

    private func addLabel(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textAlignment = .center
        label.textColor = color
        label.numberOfLines = 0
        stack.addArrangedSubview(label)
    }

    private func style(_ button: UIButton, primary: Bool) {
        button.backgroundColor = primary ? Theme.violet : .white.withAlphaComponent(0.09)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }

    @objc private func continueGame() { if verified { dismiss(animated: true) } }
    @objc private func openDeveloper() { if let url = URL(string: "https://t.me/om_g9") { UIApplication.shared.open(url) } }
    @objc private func changeLanguage() {
        arabic.toggle()
        activate.setTitle(arabic ? "تفعيل الكود ✦" : "Verify code ✦", for: .normal)
        enter.setTitle(arabic ? "دخول اللعبة ←" : "Enter game →", for: .normal)
        status.text = arabic ? "أدخل كود التفعيل" : "Enter activation code"
    }

    @objc private func openChannel() {
        guard let url = URL(string: "https://t.me/hassanyIPA") else { return }
        UIApplication.shared.open(url)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        verify()
        return true
    }

    @objc private func verify() {
        field.resignFirstResponder()
        verified = false
        enter.isHidden = true
        let code = (field.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard code.count >= 10 else {
            status.text = "أدخل كود صحيح أولاً"
            return
        }
        let base = (Bundle.main.object(forInfoDictionaryKey: "HassanyAPIBaseURL") as? String) ?? "https://backend-black-delta-89.vercel.app"
        guard base.hasPrefix("https://"), let url = URL(string: base + "/api/activate") else {
            status.text = "التفعيل يحتاج نشر وربط السيرفر أولاً"
            return
        }
        activate.isEnabled = false
        status.text = "جاري التحقق..."
        let defaults = UserDefaults.standard
        let deviceKey = "HassanyClientDeviceID"
        var device = defaults.string(forKey: deviceKey)
        if device == nil {
            device = UUID().uuidString
            defaults.set(device, forKey: deviceKey)
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 12
        req.httpBody = try? JSONSerialization.data(withJSONObject: [
            "code": code, "device_id": device ?? ""
        ])
        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            let result = (data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }) ?? [:]
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.activate.isEnabled = true
                if result["ok"] as? Bool == true {
                    self.verified = true
                    self.enter.isHidden = false
                    self.status.text = "تم التحقق ✓ اضغط دخول اللعبة"
                    self.status.textColor = .systemGreen
                } else {
                    self.verified = false
                    self.enter.isHidden = true
                    self.status.text = error == nil ? "الكود غير صالح أو انتهت صلاحيته" : "تعذّر الاتصال بالسيرفر"
                }
            }
        }.resume()
    }
}
