import UIKit
import QuartzCore

// HASSANY IPA native interface. Every surface is made with UIKit/CoreAnimation.
// No image files, UIImageView, HTML, WebView or image-backed login screens.
private enum Neon {
    static let ink = UIColor(red: 0.023, green: 0.015, blue: 0.060, alpha: 1)
    static let violet = UIColor(red: 0.71, green: 0.30, blue: 1, alpha: 1)
    static let blue = UIColor(red: 0.05, green: 0.60, blue: 1, alpha: 1)
    static let soft = UIColor(red: 0.79, green: 0.78, blue: 0.91, alpha: 1)
}

private final class GradientSurface: UIView {
    private let fill = CAGradientLayer()
    init(colors: [UIColor], radius: CGFloat = 16, border: UIColor = Neon.violet) {
        super.init(frame: .zero)
        fill.colors = colors.map { $0.cgColor }
        fill.startPoint = CGPoint(x: 0, y: 0)
        fill.endPoint = CGPoint(x: 1, y: 1)
        fill.cornerRadius = radius
        layer.insertSublayer(fill, at: 0)
        layer.cornerRadius = radius
        layer.borderColor = border.withAlphaComponent(0.82).cgColor
        layer.borderWidth = 1.2
        layer.shadowColor = border.cgColor
        layer.shadowRadius = 16
        layer.shadowOpacity = 0.32
        layer.shadowOffset = .zero
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }
    override func layoutSubviews() {
        super.layoutSubviews()
        fill.frame = bounds
        fill.cornerRadius = layer.cornerRadius
    }
    func animateGlow() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        let pulse = CABasicAnimation(keyPath: "shadowOpacity")
        pulse.fromValue = 0.16
        pulse.toValue = 0.52
        pulse.duration = 2.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        layer.add(pulse, forKey: "nativeNeonPulse")
    }
}

private final class NeonScene: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = true
        contentMode = .redraw
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let colors = [Neon.ink.cgColor,
                      UIColor(red: 0.11, green: 0.035, blue: 0.22, alpha: 1).cgColor,
                      UIColor(red: 0.01, green: 0.10, blue: 0.20, alpha: 1).cgColor]
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray,
                                     locations: [0, 0.46, 1]) {
            ctx.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: rect.maxX, y: rect.maxY), options: [])
        }
        // Abstract pool-table contours and premium neon ambience drawn as vectors.
        ctx.setLineWidth(2)
        let w = rect.width, h = rect.height
        for idx in 0..<7 {
            let fraction = CGFloat(idx) / 6
            ctx.setStrokeColor(UIColor(red: 0.45, green: 0.20, blue: 0.9, alpha: 0.08 + 0.05*fraction).cgColor)
            ctx.move(to: CGPoint(x: fraction * w, y: 0))
            ctx.addLine(to: CGPoint(x: fraction * w - 0.20*w, y: h))
            ctx.strokePath()
        }
        ctx.setStrokeColor(Neon.blue.withAlphaComponent(0.35).cgColor)
        ctx.setLineWidth(3)
        ctx.stroke(CGRect(x: -20, y: h*0.82, width: w+40, height: h*0.20))
        ctx.setFillColor(Neon.violet.withAlphaComponent(0.15).cgColor)
        ctx.fillEllipse(in: CGRect(x: -90, y: h*0.56, width: 220, height: 220))
        drawBall(ctx, x: w*0.11, y: h*0.80, radius: min(h*0.15, 57), number: "8")
        drawBall(ctx, x: w*0.91, y: h*0.88, radius: min(h*0.085, 35), number: "2")
    }
    private func drawBall(_ ctx: CGContext, x: CGFloat, y: CGFloat, radius r: CGFloat, number: String) {
        let ellipse = CGRect(x: x-r, y: y-r, width: r*2, height: r*2)
        ctx.saveGState()
        ctx.addEllipse(in: ellipse)
        ctx.clip()
        if let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                              colors: [UIColor(red: 0.56, green: 0.35, blue: 0.85, alpha: 1).cgColor,
                                       UIColor(red: 0.055, green: 0.045, blue: 0.11, alpha: 1).cgColor,
                                       UIColor.black.cgColor] as CFArray,
                              locations: [0,0.40,1]) {
            ctx.drawLinearGradient(g, start: CGPoint(x:x-r, y:y-r), end: CGPoint(x:x+r,y:y+r), options: [])
        }
        ctx.restoreGState()
        let spot = CGRect(x: x-r*0.43, y: y-r*0.36, width: r*0.93, height: r*0.93)
        ctx.setFillColor(UIColor.white.withAlphaComponent(0.89).cgColor)
        ctx.fillEllipse(in: spot)
        let text = NSAttributedString(string: number, attributes: [
            .font: UIFont.systemFont(ofSize: r*0.62, weight: .heavy),
            .foregroundColor: UIColor.black])
        let size = text.size()
        text.draw(at: CGPoint(x: spot.midX-size.width/2, y: spot.midY-size.height/2))
    }
}

private func label(_ color: UIColor = .white, weight: UIFont.Weight = .regular) -> UILabel {
    let item = UILabel()
    item.textColor = color
    item.font = .systemFont(ofSize: 15, weight: weight)
    item.textAlignment = .center
    item.numberOfLines = 0
    item.adjustsFontSizeToFitWidth = true
    item.minimumScaleFactor = 0.7
    return item
}

@objc(HassanyBridge)
public final class HassanyBridge: NSObject {
    @objc(presentOn:)
    public static func present(on presenter: UIViewController) {
        guard presenter.presentedViewController == nil else { return }
        let screen = HassanyNativeWelcome()
        screen.modalPresentationStyle = .overFullScreen
        presenter.present(screen, animated: false)
    }
}

private final class HassanyNativeWelcome: UIViewController, UITextFieldDelegate {
    private let scene = NeonScene()
    private let framePanel = GradientSurface(colors: [
        UIColor(red: 0.06, green: 0.035, blue: 0.13, alpha: 0.96),
        UIColor(red: 0.018, green: 0.028, blue: 0.09, alpha: 0.97)
    ], radius: 22)
    private let formPanel = GradientSurface(colors: [
        UIColor(red: 0.070, green: 0.040, blue: 0.15, alpha: 0.94),
        UIColor(red: 0.025, green: 0.040, blue: 0.12, alpha: 0.96)
    ], radius: 18)
    private let branding = UIView()
    private let phone = UIView()
    private let phoneMark = label()
    private let logo = label(.white, weight: .heavy)
    private let brand = label(.white, weight: .heavy)
    private let tagline = label(Neon.soft, weight: .medium)
    private let crown = label(Neon.violet, weight: .heavy)
    private let intro = label(.white, weight: .heavy)
    private let heading = label(.white, weight: .heavy)
    private let subheading = label(Neon.soft, weight: .medium)
    private let separator = UIView()
    private let codeField = UITextField()
    private let verify = GradientSurface(colors: [Neon.violet, UIColor(red:0.36,green:0.16,blue:0.79,alpha:1)],border:Neon.violet)
    private let verifyButton = UIButton(type: .system)
    private let enter = GradientSurface(colors: [UIColor(red:0.02,green:0.27,blue:0.48,alpha:1), UIColor(red:0.025,green:0.07,blue:0.19,alpha:1)],border:Neon.blue)
    private let enterButton = UIButton(type: .system)
    private let status = label(Neon.soft, weight: .medium)
    private let channelButton = UIButton(type: .system)
    private let developerButton = UIButton(type: .system)
    private let languageButton = UIButton(type: .system)
    private let activity = UIActivityIndicatorView(style: .medium)
    private var isArabic = true
    private var verified = false
    private var serverReady = false
    private var maintenance = false
    private var forceUpdate = false
    private let version = "7.0"
    private let base = "https://backend-black-delta-89.vercel.app"

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scene)
        view.addSubview(framePanel)
        framePanel.addSubview(branding)
        framePanel.addSubview(formPanel)
        phone.backgroundColor = UIColor(red:0.015,green:0.02,blue:0.08,alpha:1)
        phone.layer.cornerRadius = 18
        phone.layer.borderWidth = 2
        phone.layer.borderColor = Neon.blue.withAlphaComponent(0.87).cgColor
        phone.layer.shadowColor = Neon.violet.cgColor
        phone.layer.shadowOpacity = 0.58
        phone.layer.shadowRadius = 16
        branding.addSubview(phone)
        [phoneMark, logo, brand, tagline, crown].forEach { branding.addSubview($0) }
        phoneMark.text = "◇"
        crown.text = "♛"
        logo.text = "HIPA"
        logo.layer.shadowColor = Neon.violet.cgColor
        logo.layer.shadowRadius = 14
        logo.layer.shadowOpacity = 0.95
        logo.layer.shadowOffset = .zero
        brand.text = "hassany IPA"
        tagline.text = "تعديل تطبيقات الآيفون\n© حسين الحسني"
        [intro, heading, subheading, separator, codeField, verify, enter, status,
         channelButton, developerButton, languageButton, activity].forEach { formPanel.addSubview($0) }

        separator.backgroundColor = Neon.violet.withAlphaComponent(0.6)
        codeField.textColor = .white
        codeField.autocorrectionType = .no
        codeField.autocapitalizationType = .allCharacters
        codeField.spellCheckingType = .no
        codeField.returnKeyType = .done
        codeField.keyboardAppearance = .dark
        codeField.textAlignment = .center
        codeField.layer.cornerRadius = 10
        codeField.layer.borderWidth = 1
        codeField.layer.borderColor = Neon.violet.cgColor
        codeField.backgroundColor = UIColor(red:0.02,green:0.025,blue:0.08,alpha:0.98)
        codeField.delegate = self
        verify.addSubview(verifyButton)
        enter.addSubview(enterButton)
        for (b,action) in [(verifyButton,#selector(checkCode)),(enterButton,#selector(goToGame)),
                           (channelButton,#selector(openChannel)),(developerButton,#selector(openDeveloper)),
                           (languageButton,#selector(switchLanguage))] {
            b.addTarget(self, action: action, for: .touchUpInside)
            b.setTitleColor(.white, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        }
        for b in [channelButton, developerButton, languageButton] {
            b.backgroundColor = UIColor(red:0.15,green:0.11,blue:0.26,alpha:0.72)
            b.layer.cornerRadius = 10
            b.layer.borderWidth = 1
            b.layer.borderColor = Neon.violet.withAlphaComponent(0.52).cgColor
        }
        activity.hidesWhenStopped = true
        activity.color = .white
        enter.isHidden = true
        enterButton.isEnabled = false
        localize()
        status.text = "جاري الاتصال بالسيرفر..."
        if !UIAccessibility.isReduceMotionEnabled {
            framePanel.alpha = 0
            framePanel.transform = CGAffineTransform(scaleX:0.94, y:0.94)
            UIView.animate(withDuration: 0.67, delay: 0, usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0.22, options: [.curveEaseOut]) {
                self.framePanel.alpha = 1
                self.framePanel.transform = .identity
            }
            formPanel.animateGlow()
        }
        loadStatus()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scene.frame = view.bounds
        let safe = view.safeAreaLayoutGuide.layoutFrame
        let margin: CGFloat = 5
        let outer = safe.insetBy(dx: margin,dy: margin)
        framePanel.frame = outer
        let w = outer.width, h = outer.height
        let leftWidth = w * (w > h ? 0.37 : 0.0)
        branding.isHidden = leftWidth == 0
        branding.frame = CGRect(x: 0,y: 0,width: leftWidth,height: h)
        formPanel.frame = CGRect(x: leftWidth + 5,y: 6,width:w-leftWidth-11,height:h-12)
        let ph = formPanel.bounds.height
        let pw = formPanel.bounds.width
        let s = ph / 350
        let inset = max(12,pw*0.07)
        func put(_ v:UIView,_ x:CGFloat,_ y:CGFloat,_ wi:CGFloat,_ he:CGFloat) {
            v.frame = CGRect(x:x,y:y,width:wi,height:he)
        }
        if leftWidth > 0 {
            let mid = leftWidth/2
            let phoneW = min(leftWidth*0.43,h*0.38)
            put(phone,mid-phoneW/2,h*0.075,phoneW,h*0.40)
            put(phoneMark,mid-phoneW/2,h*0.075,phoneW,h*0.28)
            put(crown,mid-phoneW*0.40,h*0.01,phoneW*0.8,h*0.17)
            put(logo,0,h*0.28,leftWidth,h*0.25)
            put(brand,0,h*0.56,leftWidth,h*0.14)
            put(tagline,10,h*0.73,leftWidth-20,h*0.18)
            logo.font = .systemFont(ofSize:max(22,78*s),weight:.black)
            brand.font = .systemFont(ofSize:max(12,26*s),weight:.heavy)
            tagline.font = .systemFont(ofSize:max(9,12*s),weight:.medium)
            crown.font = .systemFont(ofSize:max(22,53*s),weight:.heavy)
            phoneMark.font = .systemFont(ofSize:max(18,48*s),weight:.light)
        }
        put(languageButton,pw-135*s-14,9*s,135*s,31*s)
        put(intro,inset,13*s,pw-2*inset,29*s)
        put(heading,inset,43*s,pw-2*inset,43*s)
        put(subheading,inset,91*s,pw-2*inset,25*s)
        put(separator,inset,120*s,pw-2*inset,1)
        put(codeField,inset,132*s,pw-2*inset,46*s)
        put(verify,inset,186*s,pw-2*inset,43*s)
        verifyButton.frame = verify.bounds
        put(enter,inset,234*s,pw-2*inset,42*s)
        enterButton.frame = enter.bounds
        put(status,inset,281*s,pw-2*inset,23*s)
        let half = (pw-2*inset-9)/2
        put(channelButton,inset,309*s,half,34*s)
        put(developerButton,inset+half+9,309*s,half,34*s)
        activity.center = CGPoint(x:verify.frame.minX+18,y:verify.frame.midY)
        intro.font = .systemFont(ofSize:max(11,19*s),weight:.bold)
        heading.font = .systemFont(ofSize:max(17,33*s),weight:.heavy)
        subheading.font = .systemFont(ofSize:max(9,11*s),weight:.medium)
        codeField.font = .monospacedSystemFont(ofSize:max(11,17*s),weight:.semibold)
        verifyButton.titleLabel?.font = .systemFont(ofSize:max(10,17*s),weight:.bold)
        enterButton.titleLabel?.font = .systemFont(ofSize:max(10,16*s),weight:.bold)
        for b in [channelButton,developerButton] {
            b.titleLabel?.font = .systemFont(ofSize:max(9,12*s),weight:.bold)
        }
        languageButton.titleLabel?.font = .systemFont(ofSize:max(10,11*s),weight:.semibold)
        status.font = .systemFont(ofSize:max(9,11*s),weight:.medium)
    }

    private func localize() {
        intro.text = isArabic ? "✦ مرحباً بك في ✦" : "✦ Welcome to ✦"
        heading.text = "HASSANY IPA"
        subheading.text = isArabic ? "أكثر من لعبة بلياردو .. مجتمع يجمع المحترفين"
                                 : "More than billiards • A community of players"
        codeField.placeholder = isArabic ? "أدخل كود التفعيل" : "Enter activation code"
        verifyButton.setTitle(isArabic ? "◈   تحقق من الكود" : "◈   Verify code",for:.normal)
        enterButton.setTitle(isArabic ? "⟶   دخول اللعبة" : "⟶   Enter game",for:.normal)
        channelButton.setTitle("✈  @hassanyIPA",for:.normal)
        developerButton.setTitle("✦  @om_g9",for:.normal)
        languageButton.setTitle(isArabic ? "عربي  |  English" : "English  |  عربي",for:.normal)
    }
    @objc private func switchLanguage() {
        isArabic.toggle()
        localize()
    }
    @objc private func openChannel() {
        if let url=URL(string:"https://t.me/hassanyIPA") { UIApplication.shared.open(url) }
    }
    @objc private func openDeveloper() {
        if let url=URL(string:"https://t.me/om_g9") { UIApplication.shared.open(url) }
    }
    func textFieldShouldReturn(_ textField:UITextField)->Bool {
        textField.resignFirstResponder()
        checkCode()
        return true
    }
    private func updateGate() {
        let canEnter = verified && serverReady && !maintenance && !forceUpdate
        enter.isHidden = !canEnter
        enterButton.isEnabled = canEnter
    }
    private func loadStatus() {
        guard let url=URL(string:base + "/api/status") else { return }
        var req=URLRequest(url:url)
        req.timeoutInterval=12
        URLSession.shared.dataTask(with:req) { [weak self] data,response,_ in
            let result=data.flatMap { try? JSONSerialization.jsonObject(with:$0) as? [String:Any] }
            DispatchQueue.main.async {
                guard let self=self else { return }
                guard (response as? HTTPURLResponse)?.statusCode == 200, let result=result else {
                    self.serverReady=false
                    self.status.text="تعذر الاتصال بالسيرفر"
                    self.updateGate()
                    return
                }
                self.serverReady=true
                self.maintenance=(result["maintenance"] as? Bool) ?? false
                let latest=(result["latest_version"] as? String) ?? ""
                self.forceUpdate=((result["force_update"] as? Bool) ?? false)
                    && latest.compare(self.version, options:.numeric) == .orderedDescending
                if self.maintenance {
                    self.status.text=(result["maintenance_message"] as? String) ?? "الخدمة تحت الصيانة"
                } else if self.forceUpdate {
                    self.status.text="تحديث جديد مطلوب"
                } else {
                    self.status.text="النظام متصل • أدخل كود التفعيل"
                }
                self.updateGate()
            }
        }.resume()
    }
    @objc private func checkCode() {
        codeField.resignFirstResponder()
        verified=false
        updateGate()
        guard serverReady && !maintenance && !forceUpdate else {
            status.text="النظام غير متاح حالياً"
            return
        }
        let code=(codeField.text ?? "").trimmingCharacters(in:.whitespacesAndNewlines)
        guard (10...100).contains(code.count),
              let url=URL(string:base + "/api/activate") else {
            status.text="أدخل كود التفعيل بشكل صحيح"
            return
        }
        let key="HassanyClientDeviceID"
        var device=UserDefaults.standard.string(forKey:key)
        if device == nil {
            device=UUID().uuidString
            UserDefaults.standard.set(device,forKey:key)
        }
        var req=URLRequest(url:url)
        req.httpMethod="POST"
        req.timeoutInterval=15
        req.setValue("application/json",forHTTPHeaderField:"Content-Type")
        req.httpBody=try? JSONSerialization.data(withJSONObject:["code":code,"device_id":device ?? ""])
        verifyButton.isEnabled=false
        activity.startAnimating()
        status.text="جاري التحقق من الكود..."
        URLSession.shared.dataTask(with:req) { [weak self] data,response,error in
            let result=data.flatMap { try? JSONSerialization.jsonObject(with:$0) as? [String:Any] } ?? [:]
            DispatchQueue.main.async {
                guard let self=self else { return }
                self.verifyButton.isEnabled=true
                self.activity.stopAnimating()
                if (response as? HTTPURLResponse)?.statusCode == 200
                    && result["ok"] as? Bool == true
                    && self.serverReady && !self.maintenance && !self.forceUpdate {
                    self.verified=true
                    self.status.text="✓ تم التفعيل • يمكنك دخول اللعبة"
                    self.status.textColor=.systemGreen
                } else {
                    self.verified=false
                    if result["error"] as? String == "maintenance" {
                        self.maintenance=true
                        self.status.text="الخدمة تحت الصيانة"
                    } else {
                        self.status.text=error == nil ? "الكود غير صالح أو منتهي" : "تعذر الاتصال بالسيرفر"
                    }
                }
                self.updateGate()
            }
        }.resume()
    }
    @objc private func goToGame() {
        guard verified && serverReady && !maintenance && !forceUpdate else { return }
        dismiss(animated:true)
    }
}
