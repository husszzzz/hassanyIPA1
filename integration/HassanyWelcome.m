#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

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
    self.view.backgroundColor = [UIColor colorWithRed:.08 green:.04 blue:.15 alpha:1];
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 18;
    stack.alignment = UIStackViewAlignmentFill;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerYAnchor],
        [stack.widthAnchor constraintLessThanOrEqualToConstant:340],
        [stack.widthAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.widthAnchor multiplier:.85]
    ]];
    UILabel *title = [UILabel new];
    title.text = @"HASSANY IPA";
    title.textColor = UIColor.whiteColor;
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:32];
    [stack addArrangedSubview:title];
    UILabel *subtitle = [UILabel new];
    subtitle.text = @"أهلاً وسهلاً بك في HASSANY IPA";
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
    _codeField.placeholder = @"أدخل كود التفعيل";
    _codeField.borderStyle = UITextBorderStyleRoundedRect;
    _codeField.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:_codeField];
    UIButton *activate = [UIButton buttonWithType:UIButtonTypeSystem];
    [activate setTitle:@"تفعيل" forState:UIControlStateNormal];
    [activate addTarget:self action:@selector(activateCode) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:activate];
    _statusLabel = [UILabel new];
    _statusLabel.text = @"السيرفر غير مربوط بعد";
    _statusLabel.textColor = UIColor.lightGrayColor;
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:_statusLabel];
    UIButton *continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [continueButton setTitle:@"متابعة إلى اللعبة" forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueToGame) forControlEvents:UIControlEventTouchUpInside];
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
static BOOL hassanyDidPresent = NO;
static void HassanyTryPresent(void) {
    if (hassanyDidPresent) return;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidBecomeActiveNotification
                                                        object:nil
                                                         queue:NSOperationQueue.mainQueue
                                                    usingBlock:^(NSNotification *note) { HassanyScheduleWelcome(note); }];
        HassanyScheduleWelcome(nil);
    });
}
