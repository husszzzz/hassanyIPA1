#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// Hassany native welcome overlay: standalone component for authorized integration.
// It does not patch or inject into any third-party executable by itself.
@interface HassanyWelcomeController : UIViewController
@end
@implementation HassanyWelcomeController {
    UILabel *_statusLabel;
    UITextField *_codeField;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:.025 green:.020 blue:.080 alpha:1];
    CAGradientLayer *background = [CAGradientLayer layer];
    background.colors = @[(id)[UIColor colorWithRed:.04 green:.03 blue:.11 alpha:1].CGColor,
                           (id)[UIColor colorWithRed:.17 green:.08 blue:.31 alpha:1].CGColor,
                           (id)[UIColor colorWithRed:.04 green:.06 blue:.15 alpha:1].CGColor];
    background.startPoint = CGPointMake(0, 0);
    background.endPoint = CGPointMake(1, 1);
    background.frame = UIScreen.mainScreen.bounds;
    [self.view.layer insertSublayer:background atIndex:0];
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 13;
    stack.alignment = UIStackViewAlignmentFill;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];
    [scroll addSubview:stack];
    stack.layoutMarginsRelativeArrangement = YES;
    stack.layoutMargins = UIEdgeInsetsMake(20, 20, 20, 20);
    stack.backgroundColor = [UIColor colorWithRed:.09 green:.07 blue:.18 alpha:.96];
    stack.layer.cornerRadius = 24;
    stack.layer.borderWidth = 1;
    stack.layer.borderColor = [UIColor colorWithRed:.55 green:.37 blue:.94 alpha:.6].CGColor;
    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [stack.centerXAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.centerXAnchor],
        [stack.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:12],
        [stack.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-12],
        [stack.widthAnchor constraintLessThanOrEqualToConstant:340],
        [stack.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor multiplier:.85]
    ]];
    UIImage *brandImage = [UIImage imageNamed:@"HassanyWelcomeLogo"];
    if (brandImage) {
        UIImageView *brandView = [[UIImageView alloc] initWithImage:brandImage];
        brandView.contentMode = UIViewContentModeScaleAspectFit;
        [brandView.heightAnchor constraintEqualToConstant:135].active = YES;
        [stack addArrangedSubview:brandView];
    }
    UILabel *eyebrow = [UILabel new];
    eyebrow.text = @"✦  PREMIUM WELCOME  ✦";
    eyebrow.textColor = [UIColor colorWithRed:.73 green:.64 blue:1 alpha:1];
    eyebrow.textAlignment = NSTextAlignmentCenter;
    eyebrow.font = [UIFont boldSystemFontOfSize:10];
    [stack addArrangedSubview:eyebrow];
    UILabel *title = [UILabel new];
    title.text = @"HASSANY IPA";
    title.textColor = UIColor.whiteColor;
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:32 weight:UIFontWeightHeavy];
    [stack addArrangedSubview:title];
    UILabel *subtitle = [UILabel new];
    subtitle.text = @"أهلاً بيك بعالم HASSANY IPA المميز";
    subtitle.textColor = UIColor.lightGrayColor;
    subtitle.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:subtitle];
    UILabel *author = [UILabel new];
    author.text = @"المطور: @OM_G9";
    author.textColor = UIColor.whiteColor;
    author.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:author];
    UIButton *channel = [UIButton buttonWithType:UIButtonTypeSystem];
    [channel setTitle:@"قناة التلغرام @hassanyIPA" forState:UIControlStateNormal];
    [channel addTarget:self action:@selector(openChannel) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:channel];
    _codeField = [UITextField new];
    _codeField.placeholder = @"XXXX-XXXX-XXXX";
    _codeField.backgroundColor = [UIColor colorWithWhite:1 alpha:.09];
    _codeField.layer.cornerRadius = 12;
    _codeField.textColor = UIColor.whiteColor;
    _codeField.font = [UIFont monospacedSystemFontOfSize:15 weight:UIFontWeightSemibold];
    [_codeField.heightAnchor constraintEqualToConstant:44].active = YES;
    _codeField.borderStyle = UITextBorderStyleRoundedRect;
    _codeField.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:_codeField];
    UIButton *activate = [UIButton buttonWithType:UIButtonTypeSystem];
    [activate setTitle:@"تفعيل" forState:UIControlStateNormal];
    [activate addTarget:self action:@selector(activateCode) forControlEvents:UIControlEventTouchUpInside];
    activate.backgroundColor = [UIColor colorWithRed:.46 green:.27 blue:.93 alpha:1];
    activate.layer.cornerRadius = 12;
    [activate setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [activate.heightAnchor constraintEqualToConstant:44].active = YES;
    [stack addArrangedSubview:activate];
    _statusLabel = [UILabel new];
    _statusLabel.text = @"السيرفر غير مربوط بعد";
    _statusLabel.textColor = UIColor.lightGrayColor;
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:_statusLabel];
    UIButton *continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [continueButton setTitle:@"متابعة إلى اللعبة" forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueToGame) forControlEvents:UIControlEventTouchUpInside];
    continueButton.backgroundColor = [UIColor colorWithWhite:1 alpha:.10];
    continueButton.layer.cornerRadius = 12;
    [continueButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [continueButton.heightAnchor constraintEqualToConstant:44].active = YES;
    [stack addArrangedSubview:continueButton];
}
- (void)openChannel {
    NSURL *url = [NSURL URLWithString:@"https://t.me/hassanyIPA"];
    [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
}
- (void)continueToGame { [self dismissViewControllerAnimated:YES completion:nil]; }
- (void)activateCode {
    _statusLabel.text = @"التفعيل غير مفعّل قبل ربط السيرفر";
}
@end

// Explicit entry point, to be invoked by the authorized game integration.
__attribute__((visibility("default")))
void HassanyPresentWelcome(UIViewController *presenter) {
    if (!presenter || presenter.presentedViewController) return;
    HassanyWelcomeController *welcome = [HassanyWelcomeController new];
    welcome.modalPresentationStyle = UIModalPresentationFullScreen;
    [presenter presentViewController:welcome animated:YES completion:nil];
}

// Experimental startup integration. Runs once when UIKit is active.
// Prevent legacy welcome panels in the authorized XO-derived build.
// No game logic or activation checks are changed.
static void HassanyNoLegacyWelcome(id object, SEL selector) {
    (void)object;
    (void)selector;
}
static void HassanyMuteOldWelcome(void) {
    Class cls = objc_getClass("WelcomeManager");
    if (!cls) return;
    const char *names[] = {"presentWelcomeIfNeeded", "tryPresent", "presentWelcome"};
    for (unsigned i = 0; i < sizeof(names)/sizeof(names[0]); ++i) {
        Method m = class_getInstanceMethod(cls, sel_registerName(names[i]));
        if (m && method_getNumberOfArguments(m) == 2) {
            method_setImplementation(m, (IMP)HassanyNoLegacyWelcome);
        }
    }
}
static BOOL hassanyDidPresent = NO;
static void HassanyTryPresent(void) {
    if (hassanyDidPresent) return;
    HassanyMuteOldWelcome();
    UIApplication *app = UIApplication.sharedApplication;
    UIWindow *window = nil;
    for (UIScene *scene in app.connectedScenes) {
        if (![scene isKindOfClass:UIWindowScene.class] ||
            scene.activationState != UISceneActivationStateForegroundActive) continue;
        for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
            if (candidate.isKeyWindow) { window = candidate; break; }
        }
        if (window) break;
    }
    if (!window) window = app.keyWindow;
    UIViewController *controller = window.rootViewController;
    if (!controller || controller.presentedViewController) return;
    hassanyDidPresent = YES;
    HassanyPresentWelcome(controller);
}
static void HassanyScheduleWelcome(__unused NSNotification *notice) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ HassanyTryPresent(); });
}
__attribute__((constructor)) static void HassanyBootstrap(void) {
    HassanyMuteOldWelcome();
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidBecomeActiveNotification
                                                        object:nil
                                                         queue:NSOperationQueue.mainQueue
                                                    usingBlock:^(NSNotification *note) { HassanyScheduleWelcome(note); }];
        HassanyScheduleWelcome(nil);
    });
}
