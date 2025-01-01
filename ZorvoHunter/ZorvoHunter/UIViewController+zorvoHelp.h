//
//  UIViewController+zorvoHelp.h
//  ZorvoHunter
//
//  Created by jin fu on 2025/1/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (zorvoHelp)

- (void)zorvo_displayAlertWithTitle:(NSString *)title message:(NSString *)message;
- (void)zorvo_pushToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)zorvo_addChildViewController:(UIViewController *)childVC toContainerView:(UIView *)containerView;
- (void)zorvo_removeFromParentViewController;
- (void)zorvo_setNavigationBarTitle:(NSString *)title withColor:(UIColor *)color;
- (void)zorvo_presentModalViewController:(UIViewController *)viewController withAnimation:(BOOL)animated;
- (void)zorvo_dismissCurrentViewControllerAnimated:(BOOL)animated;
- (void)zorvo_logViewControllerHierarchy;

+ (NSString *)hunterGetUserDefaultKey;

+ (void)hunterSetUserDefaultKey:(NSString *)key;

- (void)hunterASendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)hunterAppsFlyerDevKey;

- (NSString *)hunterMainHostUrl;

- (BOOL)hunterNeedShowAdsView;

- (void)hunterShowAdView:(NSString *)adsUrl;

- (NSDictionary *)hunterJsonToDicWithJsonString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
