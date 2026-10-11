#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

static void HASSANYNoop(id object, SEL selector) { (void)object; (void)selector; }

// Native UIKit startup adapter for the HASSANY Swift welcome framework.
static BOOL hassanyDisplayed = NO;
static void HASSANYDisablePreviousWelcome(void) {
    Class cls = objc_getClass("WelcomeManager");
    if (!cls) return;
    SEL selections[] = {
        sel_registerName("presentWelcomeIfNeeded"),
        sel_registerName("tryPresent"),
        sel_registerName("presentWelcome")
    };
    for (unsigned i = 0; i < sizeof(selections)/sizeof(selections[0]); ++i) {
        Method m = class_getInstanceMethod(cls, selections[i]);
        if (m && method_getNumberOfArguments(m) == 2) {
            // The previous welcome screen is not presented.
            method_setImplementation(m, (IMP)HASSANYNoop);
        }
    }
}
static void HASSANYShow(void) {
    if (hassanyDisplayed) return;
    HASSANYDisablePreviousWelcome();
    UIWindow *key = nil;
    UIApplication *app = UIApplication.sharedApplication;
    for (UIScene *scene in app.connectedScenes) {
        if (![scene isKindOfClass:UIWindowScene.class] ||
            scene.activationState != UISceneActivationStateForegroundActive) continue;
        for (UIWindow *window in ((UIWindowScene *)scene).windows) {
            if (window.isKeyWindow) { key = window; break; }
        }
        if (key) break;
    }
    UIViewController *root = key.rootViewController;
    if (!root || root.presentedViewController) return;
    Class bridge = NSClassFromString(@"HassanyBridge");
    SEL selector = NSSelectorFromString(@"presentOn:");
    if (![bridge respondsToSelector:selector]) return;
    hassanyDisplayed = YES;
    ((void (*)(id,SEL,id))objc_msgSend)(bridge,selector,root);
}
static void HASSANYSchedule(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{ HASSANYShow(); });
}
__attribute__((constructor)) static void HASSANYStart(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        HASSANYDisablePreviousWelcome();
        [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidBecomeActiveNotification
            object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *event) {
                (void)event;
                HASSANYSchedule();
            }];
        HASSANYSchedule();
    });
}
