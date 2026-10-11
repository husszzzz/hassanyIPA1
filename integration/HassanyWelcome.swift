import UIKit

@objc(HassanyBridge)
public final class HassanyBridge: NSObject {
    @objc(presentOn:)
    public static func present(on presenter: UIViewController) {
        guard presenter.presentedViewController == nil else { return }
        let screen = PremiumWelcome()
        screen.modalPresentationStyle = .overFullScreen
        presenter.present(screen, animated: false)
    }
}

private final class PremiumWelcome: UIViewController, UITextFieldDelegate {
    private let backdrop = UIImageView()
    private let panel = UIView()
    private let codeField = UITextField()
    private let info = UILabel()
    private let blocked = UIView()
    private let verifyButton = UIButton(type: .custom)
    private let enterButton = UIButton(type: .custom)
    private let developerButton = UIButton(type: .custom)
    private let channelButton = UIButton(type: .custom)
    private let languageButton = UIButton(type: .custom)
    private let activity = UIActivityIndicatorView(style: .medium)
    private let design = CGSize(width: 1672, height: 941)
    private let api = "https://backend-black-delta-89.vercel.app"
    private var isActive = false
    private var available = false
    private var maintenance = false
    private var requireUpdate = false
    private var arabic = true
    private var keyboardOffset: CGFloat = 0

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.04, green: 0.025, blue: 0.10, alpha: 1)
        panel.clipsToBounds = true
        view.addSubview(panel)
        if let file = Bundle.main.path(forResource: "HassanyPremiumBackdrop", ofType: "png") {
            backdrop.image = UIImage(contentsOfFile: file)
        }
        backdrop.contentMode = .scaleToFill
        panel.addSubview(backdrop)
        codeField.backgroundColor = UIColor(red: 0.08, green: 0.065, blue: 0.16, alpha: 0.97)
        codeField.textColor = .white
        codeField.layer.cornerRadius = 12
        codeField.layer.borderWidth = 1
        codeField.layer.borderColor = UIColor(red: 0.70, green: 0.46, blue: 1.0, alpha: 1).cgColor
        codeField.autocapitalizationType = .allCharacters
        codeField.autocorrectionType = .no
        codeField.spellCheckingType = .no
        codeField.textAlignment = .center
        codeField.keyboardAppearance = .dark
        codeField.returnKeyType = .done
        codeField.delegate = self
        panel.addSubview(codeField)
        blocked.isUserInteractionEnabled = false
        blocked.backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.09, alpha: 0.74)
        blocked.layer.cornerRadius = 18
        panel.addSubview(blocked)

        info.numberOfLines = 2
        info.adjustsFontSizeToFitWidth = true
        info.minimumScaleFactor = 0.5
        info.textAlignment = .center
        info.backgroundColor = UIColor(red: 0.03, green: 0.025, blue: 0.09, alpha: 0.83)
        info.textColor = .white
        info.clipsToBounds = true
        info.layer.cornerRadius = 9
        panel.addSubview(info)

        for button in [verifyButton, enterButton, developerButton, channelButton, languageButton] {
            button.backgroundColor = .clear
            panel.addSubview(button)
        }
        verifyButton.addTarget(self, action: #selector(verify), for: .touchUpInside)
        enterButton.addTarget(self, action: #selector(enterGame), for: .touchUpInside)
        developerButton.addTarget(self, action: #selector(openDeveloper), for: .touchUpInside)
        channelButton.addTarget(self, action: #selector(openChannel), for: .touchUpInside)
        languageButton.addTarget(self, action: #selector(changeLanguage), for: .touchUpInside)
        verifyButton.accessibilityLabel = "تحقق من الكود"
        enterButton.accessibilityLabel = "دخول اللعبة"
        developerButton.accessibilityLabel = "المطور حسين الحسني"
        channelButton.accessibilityLabel = "قناة hassanyIPA"
        languageButton.accessibilityLabel = "اللغة"
        activity.hidesWhenStopped = true
        activity.color = .white
        panel.addSubview(activity)
        setMessage("جاري فحص حالة النظام...")
        updateEntry()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        checkStatus()
        if !UIAccessibility.isReduceMotionEnabled {
            panel.alpha = 0
            panel.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            UIView.animate(withDuration: 0.65, delay: 0, usingSpringWithDamping: 0.88,
                           initialSpringVelocity: 0.1) {
                self.panel.alpha = 1
                self.panel.transform = .identity
            }
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe = view.safeAreaLayoutGuide.layoutFrame
        let width = min(safe.width, safe.height * design.width / design.height)
        let height = width * design.height / design.width
        panel.frame = CGRect(x: safe.midX - width / 2, y: safe.midY - height / 2 - keyboardOffset, width: width, height: height)
        backdrop.frame = panel.bounds
        func box(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
            CGRect(x: x * width / design.width, y: y * height / design.height,
                   width: w * width / design.width, height: h * height / design.height)
        }
        codeField.frame = box(850, 393, 555, 90)
        codeField.font = .monospacedSystemFont(ofSize: max(12, height * 30 / design.height), weight: .semibold)
        verifyButton.frame = box(751, 502, 683, 94)
        enterButton.frame = box(751, 604, 683, 89)
        blocked.frame = enterButton.frame.insetBy(dx: 5, dy: 7)
        channelButton.frame = box(716, 757, 357, 99)
        developerButton.frame = box(1102, 757, 367, 99)
        languageButton.frame = box(1336, 14, 301, 82)
        info.frame = box(857, 699, 520, 51)
        info.font = .systemFont(ofSize: max(9, height * 25 / design.height), weight: .semibold)
        activity.frame = box(1320, 515, 36, 36)
    }

    private func setMessage(_ text: String, verified: Bool = false) {
        info.text = text
        info.textColor = verified ? .systemGreen : .white
    }
    private func updateEntry() {
        let allowed = isActive && available && !maintenance && !requireUpdate
        blocked.isHidden = allowed
        enterButton.isEnabled = allowed
    }
    @objc private func openDeveloper() {
        if let url = URL(string: "https://t.me/om_g9") { UIApplication.shared.open(url) }
    }
    @objc private func openChannel() {
        if let url = URL(string: "https://t.me/hassanyIPA") { UIApplication.shared.open(url) }
    }
    @objc private func changeLanguage() {
        arabic.toggle()
        codeField.placeholder = arabic ? "أدخل كود التفعيل" : "Activation code"
        setMessage(arabic ? "أدخل كود التفعيل" : "Enter your activation code")
    }
    @objc private func enterGame() {
        guard isActive && available && !maintenance && !requireUpdate else { return }
        dismiss(animated: true)
    }
    func textFieldShouldReturn(_ field: UITextField) -> Bool {
        field.resignFirstResponder()
        verify()
        return true
    }
    @objc private func keyboardHide() { keyboardOffset = 0; view.setNeedsLayout() }
    @objc private func keyboardChanged(_ event: Notification) {
        guard let rect = event.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let inView = view.convert(rect, from: nil)
        keyboardOffset = min(max(0, view.bounds.maxY - inView.minY) * 0.43, view.bounds.height * 0.25)
        view.setNeedsLayout()
    }
    private func checkStatus() {
        guard let url = URL(string: api + "/api/status") else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        URLSession.shared.dataTask(with: request) { [weak self] data, response, _ in
            let result = data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let result = result, (response as? HTTPURLResponse)?.statusCode == 200 else {
                    self.available = false
                    self.setMessage("تعذر الاتصال بالنظام")
                    self.updateEntry()
                    return
                }
                self.available = true
                self.maintenance = (result["maintenance"] as? Bool) ?? false
                let force = (result["force_update"] as? Bool) ?? false
                let latest = (result["latest_version"] as? String) ?? ""
                self.requireUpdate = force && latest.compare("6.0", options: .numeric) == .orderedDescending
                if self.maintenance {
                    self.setMessage(result["maintenance_message"] as? String ?? "وضع الصيانة")
                } else if self.requireUpdate {
                    self.setMessage("تحديث إجباري للنسخة")
                } else {
                    self.setMessage("جاهز — أدخل كود التفعيل")
                }
                self.updateEntry()
            }
        }.resume()
    }
    @objc private func verify() {
        codeField.resignFirstResponder()
        isActive = false
        updateEntry()
        guard available && !maintenance && !requireUpdate else { setMessage("الخدمة غير متاحة"); return }
        let code = (codeField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard (10...100).contains(code.count), let url = URL(string: api + "/api/activate") else {
            setMessage("أدخل كود صحيح")
            return
        }
        let storage = UserDefaults.standard
        var device = storage.string(forKey: "HassanyDevice")
        if device == nil { device = UUID().uuidString; storage.set(device, forKey: "HassanyDevice") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["code": code, "device_id": device ?? ""])
        verifyButton.isEnabled = false
        activity.startAnimating()
        setMessage("جاري التحقق...")
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            let result = data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] } ?? [:]
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.verifyButton.isEnabled = true
                self.activity.stopAnimating()
                if (response as? HTTPURLResponse)?.statusCode == 200 && result["ok"] as? Bool == true
                   && self.available && !self.maintenance && !self.requireUpdate {
                    self.isActive = true
                    self.setMessage("✓ الكود صحيح — اضغط دخول اللعبة", verified: true)
                } else {
                    self.isActive = false
                    self.setMessage(error != nil ? "تعذّر الاتصال" : "الكود غير صالح أو منتهي")
                }
                self.updateEntry()
            }
        }.resume()
    }
}
