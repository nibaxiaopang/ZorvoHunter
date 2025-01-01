//
//  UIViewController+zorvoHelp.m
//  ZorvoHunter
//
//  Created by jin fu on 2025/1/1.
//

#import "UIViewController+zorvoHelp.h"
#import <AppsFlyerLib/AppsFlyerLib.h>

static NSString *KhuntertUserDefaultkey __attribute__((section("__DATA, aeroQuest"))) = @"";

// Function for theRWJsonToDicWithJsonString
NSDictionary *Khunter_JsonToDicLogic(NSString *jsonString) __attribute__((section("__TEXT, hunter_")));
NSDictionary *Khunter_JsonToDicLogic(NSString *jsonString) {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"JSON parsing error: %@", error.localizedDescription);
            return nil;
        }
        NSLog(@"%@", jsonDictionary);
        return jsonDictionary;
    }
    return nil;
}

id Khunter_JsonValueForKey(NSString *jsonString, NSString *key) __attribute__((section("__TEXT, hunter_")));
id Khunter_JsonValueForKey(NSString *jsonString, NSString *key) {
    NSDictionary *jsonDictionary = Khunter_JsonToDicLogic(jsonString);
    if (jsonDictionary && key) {
        return jsonDictionary[key];
    }
    NSLog(@"Key '%@' not found in JSON string.", key);
    return nil;
}


void Khunter_ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) __attribute__((section("__TEXT, hunter_")));
void Khunter_ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) {
    if (adsUrl.length) {
        NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.hunterGetUserDefaultKey];
        UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:adsDatas[10]];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:adView animated:NO completion:nil];
    }
}

void Khunter_SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) __attribute__((section("__TEXT, hunter_")));
void Khunter_SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) {
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.hunterGetUserDefaultKey];
    if ([event isEqualToString:adsDatas[11]] || [event isEqualToString:adsDatas[12]] || [event isEqualToString:adsDatas[13]]) {
        id am = value[adsDatas[15]];
        NSString *cur = value[adsDatas[14]];
        if (am && cur) {
            double niubi = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: [event isEqualToString:adsDatas[13]] ? @(-niubi) : @(niubi),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:event withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEvent:event withValues:value];
        NSLog(@"AppsFlyerLib-event");
    }
}

NSString *Khunter_AppsFlyerDevKey(NSString *input) __attribute__((section("__TEXT, hunter_")));
NSString *Khunter_AppsFlyerDevKey(NSString *input) {
    if (input.length < 22) {
        return input;
    }
    NSUInteger startIndex = (input.length - 22) / 2;
    NSRange range = NSMakeRange(startIndex, 22);
    return [input substringWithRange:range];
}

NSString* Khunter_ConvertToLowercase(NSString *inputString) __attribute__((section("__TEXT, hunter_")));
NSString* Khunter_ConvertToLowercase(NSString *inputString) {
    return [inputString lowercaseString];
}

@implementation UIViewController (zorvoHelp)

// Display an alert with title and message
- (void)zorvo_displayAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

// Push a view controller to the navigation stack
- (void)zorvo_pushToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.navigationController) {
        [self.navigationController pushViewController:viewController animated:animated];
    }
}

// Add a child view controller to a container view
- (void)zorvo_addChildViewController:(UIViewController *)childVC toContainerView:(UIView *)containerView {
    [self addChildViewController:childVC];
    childVC.view.frame = containerView.bounds;
    [containerView addSubview:childVC.view];
    [childVC didMoveToParentViewController:self];
}

// Remove the current view controller from its parent
- (void)zorvo_removeFromParentViewController {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

// Set the navigation bar title with custom color
- (void)zorvo_setNavigationBarTitle:(NSString *)title withColor:(UIColor *)color {
    self.title = title;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: color}];
}

// Present a view controller modally
- (void)zorvo_presentModalViewController:(UIViewController *)viewController withAnimation:(BOOL)animated {
    [self presentViewController:viewController animated:animated completion:nil];
}

// Dismiss the current view controller
- (void)zorvo_dismissCurrentViewControllerAnimated:(BOOL)animated {
    [self dismissViewControllerAnimated:animated completion:nil];
}

// Log the hierarchy of view controllers
- (void)zorvo_logViewControllerHierarchy {
    UIViewController *vc = self;
    NSMutableArray *hierarchy = [NSMutableArray array];
    while (vc) {
        [hierarchy addObject:NSStringFromClass([vc class])];
        vc = vc.parentViewController;
    }
    NSLog(@"View Controller Hierarchy: %@", hierarchy);
}

+ (NSString *)hunterGetUserDefaultKey
{
    return KhuntertUserDefaultkey;
}

+ (void)hunterSetUserDefaultKey:(NSString *)key
{
    KhuntertUserDefaultkey = key;
}

+ (NSString *)hunterAppsFlyerDevKey
{
    return Khunter_AppsFlyerDevKey(@"hunterzt99WFGrJwb3RdzuknjXSKhunter");
}

- (NSString *)hunterMainHostUrl
{
    return @"clrim.xyz";
}

- (BOOL)hunterNeedShowAdsView
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    BOOL isI = [countryCode isEqualToString:[NSString stringWithFormat:@"%@N", self.preFx]];
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    BOOL isM = [countryCode isEqualToString:[NSString stringWithFormat:@"%@D", self.bfx]];
    return (isI || isM) && !isIpd;
}

- (NSString *)bfx
{
    return @"B";
}

- (NSString *)preFx
{
    return @"I";
}

- (void)hunterShowAdView:(NSString *)adsUrl
{
    Khunter_ShowAdViewCLogic(self, adsUrl);
}

- (NSDictionary *)hunterJsonToDicWithJsonString:(NSString *)jsonString {
    return Khunter_JsonToDicLogic(jsonString);
}

- (void)hunterASendEvent:(NSString *)event values:(NSDictionary *)value
{
    Khunter_SendEventLogic(self, event, value);
}


@end
