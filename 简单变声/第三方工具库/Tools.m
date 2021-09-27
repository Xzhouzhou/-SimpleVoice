//
//  Tools.m
//  Project
//
//  Created by 赵昕 on 2018/9/17.
//  Copyright © 2018 赵昕. All rights reserved.
//

#import "Tools.h"
#import "UIView+Toast.h"
@implementation Tools

#pragma mark获取当前屏幕显示的viewcontroller
#pragma mark获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    //    如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else if ([appRootVC isKindOfClass:[UINavigationController class]]) {
        nextResponder = [(UINavigationController *)appRootVC topViewController];
    }else if ([appRootVC isKindOfClass:[UITabBarController class]]) {
        nextResponder = [(UITabBarController *)appRootVC selectedViewController];
    }else{
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        //        UINavigationController * nav = tabbar.selectedViewController ; 上下两种写法都行
        result=nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    
    return result;
    
}

#pragma mark获取当前window
+(UIView*)getCurrentWindow{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    // 添加到窗口
    return window;
}
#pragma mark颜色转图片
+(UIImage*)createImageWithColor: (UIColor*) color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark提示
+ (void)makeTask:(NSString *)message WithTime:(NSTimeInterval)time{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Tools getCurrentWindow] makeToast:message duration:2 position:CSToastPositionCenter];
    });
    
}

@end
