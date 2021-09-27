//
//  ViewController.h
//  简单变声
//
//  Created by 周旭 on 2021/8/30.
//

#import <UIKit/UIKit.h>

@class ViewController;

@protocol ViewControllerDelegate <NSObject>

// audio
- (void)UUInputFunctionView:(ViewController *)funcView sendVoice:(NSData *)voice time:(NSInteger)second;

@optional
- (void)recordTool:(ViewController *)recordTool didstartRecoring:(int)no;

@end

@interface ViewController : UIViewController

@property (nonatomic, retain) UIButton *btnSendMessage;
@property (nonatomic, retain) UIButton *btnChangeVoiceState;
@property (nonatomic, retain) UIButton *btnVoiceRecord;

@property (nonatomic, assign) BOOL isAbleToSendTextMessage;

//@property (nonatomic, retain) UIViewController *superVC;

@property (nonatomic, assign) id<ViewControllerDelegate>delegate;


//- (id)initWithSuperVC:(UIViewController *)superVC;

@end

