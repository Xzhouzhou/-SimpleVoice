//
//  Tools.h
//  Project
//
//  Created by 赵昕 on 2018/9/17.
//  Copyright © 2018 赵昕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tools : NSObject
#pragma mark获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC;
#pragma mark获取当前window
+(UIWindow *)getCurrentWindow;
#pragma mark颜色转图片
+(UIImage*)createImageWithColor: (UIColor*) color size:(CGSize)size;
#pragma mark提示
+ (void)makeTask:(NSString *)message WithTime:(NSTimeInterval)time;
@end

NS_ASSUME_NONNULL_END
