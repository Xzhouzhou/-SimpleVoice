//
//  ViewController.m
//  简单变声
//
//  Created by 周旭 on 2021/8/30.
//

#import "ViewController.h"
#import "Mp3Recorder.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "Tools.h"
#import "AudioConvert.h"

@interface ViewController ()<Mp3RecorderDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,AudioConvertDelegate>{
    BOOL isbeginVoiceRecord;
    Mp3Recorder *MP3;
    NSInteger playTime;
    NSTimer *playTimer;
    UILabel *placeHold;
    
    AudioConvertOutputFormat outputFormat; //输出音频格式
    
}
@property (weak, nonatomic) IBOutlet UIButton *VoiceButton;
@property (weak, nonatomic) IBOutlet UIButton *PlayButton;
@property (retain,nonatomic) AVAudioRecorder *audioRecorder;
@property (retain,nonatomic)AVAudioPlayer *player;
//三个滑条
@property (weak, nonatomic) IBOutlet UISlider *SpeedSlider;
@property (weak, nonatomic) IBOutlet UISlider *YinDiaoSlider;
@property (weak, nonatomic) IBOutlet UISlider *SuLvSlider;

//三个leable
@property (weak, nonatomic) IBOutlet UILabel *sppedLabel;
@property (weak, nonatomic) IBOutlet UILabel *yinDiaoLabel;
@property (weak, nonatomic) IBOutlet UILabel *suLvLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置按钮
    self.VoiceButton.layer.masksToBounds = YES;
    self.VoiceButton.layer.borderWidth = 0.5;
    self.VoiceButton.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.VoiceButton setTitleColor:[UIColor colorWithRed:0.129 green:0.161 blue:0.173 alpha:1] forState:UIControlStateNormal];
    [self.VoiceButton setTitleColor:[[UIColor colorWithRed:0.129 green:0.161 blue:0.173 alpha:1] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [self.VoiceButton setTitle:@"按 住 说 话" forState:UIControlStateNormal];
    [self.VoiceButton setTitle:@"松 开 结 束" forState:UIControlStateHighlighted];
    [self.VoiceButton addTarget:self action:@selector(beginRecordVoice:) forControlEvents:UIControlEventTouchDown];
    [self.VoiceButton addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
    [self.VoiceButton addTarget:self action:@selector(cancelRecordVoice:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [self.VoiceButton addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [self.VoiceButton addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    
    //播放按钮方法
    [self.PlayButton addTarget:self action:@selector(PalyVoice:) forControlEvents:UIControlEventTouchUpInside];
    
    //获取麦克风权限
    [self requestMicroPhoneAuth];
    
    //录音会话设置
    NSError*errorSession =nil;
    //得到AVAudioSession单例对象
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    
    //启动音频会话管理,此时会阻断后台音乐的播放.
    [audioSession setActive:YES error: &errorSession];

    //设置会话类型
    //类型播放和录音，此时可以录音也可以播放
    //类别 AVAudioSessionModeDefault
    //以及默认免提，外放 AVAudioSessionCategoryOptionDefaultToSpeaker
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord mode:AVAudioSessionModeDefault options:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    //配置
    NSDictionary*setting =@{
    AVFormatIDKey:@(kAudioFormatLinearPCM),//音频格式
    AVSampleRateKey:@44100.0f,//录音采样率(Hz)如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    AVNumberOfChannelsKey:@2,//音频通道数1或2
    AVEncoderBitDepthHintKey:@16,//线性音频的位深度8、16、24、32
    AVEncoderAudioQualityKey:@(AVAudioQualityMax)//录音的质量
    };
    
    //配置文件目录
    NSURL*url = [NSURL URLWithString:[self filePath]];
    
    //初始化AVAudioRecorder
    NSError*error;

    //录音
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];

    if(self.audioRecorder) {
        self.audioRecorder.delegate=self;
        self.audioRecorder.meteringEnabled=YES;
        //设置录音时长，超过这个时间后，会暂停单位是秒
//        [self.audioRecorder recordForDuration:120];
        //创建一个音频文件，并准备系统进行录制
        [self.audioRecorder prepareToRecord];
//        [self.audioRecorder stop];
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    
//    [self.audioRecorder record];//开始录音（或者暂停后，继续录音）
//
//    [self.audioRecorder pause];//暂停录音
//
//    [self.audioRecorder stop];//停止录制并关闭音频文件

    
    //三个滑动条
    //速度 <变速不变调> 范围 -50 ~ 100
    //音调  范围 -12 ~ 12
    //声音速率 范围 -50 ~ 100
    self.SpeedSlider.value=0.5;
    self.SpeedSlider.tag = 21;
    self.SpeedSlider.minimumValue=0.01;
    self.SpeedSlider.maximumValue=1.01;
    [self.SpeedSlider addTarget:self action:@selector(getValue:) forControlEvents:UIControlEventValueChanged];

    self.YinDiaoSlider.value=0.5;
    self.YinDiaoSlider.tag = 22;
    self.YinDiaoSlider.minimumValue=0.01;
    self.YinDiaoSlider.maximumValue=1.01;
    [self.YinDiaoSlider addTarget:self action:@selector(getValue:) forControlEvents:UIControlEventValueChanged];

    self.SuLvSlider.value=0.5;
    self.SuLvSlider.tag = 23;
    self.SuLvSlider.minimumValue=0.01;
    self.SuLvSlider.maximumValue=1.01;
    [self.SuLvSlider addTarget:self action:@selector(getValue:) forControlEvents:UIControlEventValueChanged];


}

- (void)getValue:(UISlider *)sender{
    //改变数值显示
    if (sender.tag == 21) {
        self.sppedLabel.text = [NSString stringWithFormat:@"%0.f",-51+sender.value*100];
        if ([self.sppedLabel.text isEqualToString:@"-0"] || [self.sppedLabel.text isEqualToString:@"0"]) {
            self.sppedLabel.text = @"0.0";
        }
    }

    if (sender.tag == 22) {
        self.yinDiaoLabel.text = [NSString stringWithFormat:@"%0.f",-12+sender.value*24];
        if ([self.yinDiaoLabel.text isEqualToString:@"-0"] || [self.yinDiaoLabel.text isEqualToString:@"0"]) {
            self.yinDiaoLabel.text = @"0.0";
        }
        NSLog(@"滑动条数值 ： %.2f",sender.value);
    }

    if (sender.tag == 23) {
        self.suLvLabel.text = [NSString stringWithFormat:@"%0.f",-51+sender.value*100];
        if ([self.suLvLabel.text isEqualToString:@"-0"] || [self.suLvLabel.text isEqualToString:@"0"]) {
            self.suLvLabel.text = @"0.0";
        }
    }
}





//播放器代理
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag{
    //播放完成
    [Tools makeTask:@"播放完成" WithTime:2];
}

-(void)PalyVoice:(UIButton *)button{
    


//    [self.player play];//播放录音
//    [self.player pause];//暂停播放录音
//    [self.player stop];//停止播放录音
    
//    [self.player play];//播放录音
//    [Tools makeTask:@"播放中..." WithTime:3];
    
    
//    [SVProgressHUD showWithStatus:@"正在生成..." maskType:SVProgressHUDMaskTypeNone];
    //    NSString *p =  [[NSBundle mainBundle] pathForResource:@"海阔天空" ofType:@"mp3"];
    //开始进行变音处理
    AudioConvertConfig dconfig;
    dconfig.sourceAuioPath = [[self filePath] UTF8String];
    dconfig.outputFormat = AudioConvertOutputFormat_MP3;
    dconfig.outputChannelsPerFrame = 2;
    dconfig.outputSampleRate = 22050;
    //速度 <变速不变调> 范围 -50 ~ 100
    dconfig.soundTouchTempoChange = [self.sppedLabel.text floatValue];
    //音调  范围 -12 ~ 12
    dconfig.soundTouchPitch = [self.yinDiaoLabel.text floatValue];
    //声音速率 范围 -50 ~ 100
    dconfig.soundTouchRate = [self.suLvLabel.text floatValue];
    [[AudioConvert shareAudioConvert] audioConvertBegin:dconfig withCallBackDelegate:self];


}



#pragma mark - AudioConvertDelegate
/**
 * 是否只对音频文件进行解码 默认 NO 分快执行时 不会调用此方法
 * return YES : 只解码音频 并且回调 "对音频解码动作的回调"  NO : 对音频进行变声 不会 回调 "对音频解码动作的回调"
 **/
- (BOOL)audioConvertOnlyDecode
{
    return  NO;
}
/**
 * 是否只对音频文件进行编码 默认 YES 分快执行时 不会调用此方法
 * return YES : 需要编码音频 并且回调 "对音频编码动作的回调"  NO : 不对音频进行编码 不会回调 "变声处理结果的回调"
 **/
- (BOOL)audioConvertHasEnecode
{
    return NO;
}



/**
 * 对音频变声动作的回调
 **/
- (void)audioConvertSoundTouchSuccess:(NSString *)audioPath{
    
    //播放相关设置
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:nil];
    //设置播放循环次数
    [self.player setNumberOfLoops:0];
    [self.player setVolume:1];//音量，0-1之间
    //分配播放所需的资源，并将其加入内部播放队列
    [self.player setDelegate:self];
    [self.player prepareToPlay];
    [self.player play];//播放录音
    [Tools makeTask:@"播放中..." WithTime:3];
    
}

- (void)audioConvertSoundTouchFail
{
    //变声失败
    NSLog(@"变声失败");
    
}

/**
 * 对音频解码动作的回调
 **/
- (void)audioConvertDecodeSuccess:(NSString *)audioPath {
    NSLog(@"解码成功%@",audioPath);
    
}//解码成功
- (void)audioConvertDecodeFaild{
    NSLog(@"解码失败");
}
//解码失败

/**
 * 对音频编码动作的回调
 **/
- (void)audioConvertEncodeSuccess:(NSString *)audioPath{
    NSLog(@"编码完成%@,",audioPath);
}//编码完成
- (void)audioConvertEncodeFaild{
    NSLog(@"编码失败");
    
}                        //编码失败



-(void)requestMicroPhoneAuth{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {

    }];
}

//获取沙盒路径
-(NSString*)filePath {
    NSString*path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString*filePath = [path stringByAppendingPathComponent:@"voice.wav"];
    return filePath;
}




#pragma mark - 录音touch事件
//开始进行录音
- (void)beginRecordVoice:(UIButton *)button{
    
    [self.audioRecorder record];//开始录音（或者暂停后，继续录音）
    
    playTime = 0;
    playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
//    [UUProgressHUD show];
}


//结束录音
- (void)endRecordVoice:(UIButton *)button
{
    if (playTimer) {
        [self.audioRecorder stop];//停止录制并关闭音频文件
        [playTimer invalidate];
        playTimer = nil;
        [Tools makeTask:@"录制成功" WithTime:2];
    }
}

//取消录音
- (void)cancelRecordVoice:(UIButton *)button
{
    if (playTimer) {
        [self.audioRecorder pause];//暂停录音
        [playTimer invalidate];
        playTimer = nil;
    }
    [Tools makeTask:@"取消录制" WithTime:2];
//    [UUProgressHUD dismissWithError:@"取消"];
}

//提示语
- (void)RemindDragExit:(UIButton *)button
{
//    [UUProgressHUD changeSubTitle:@"松开手指,取消发送"];
}
//提示语
- (void)RemindDragEnter:(UIButton *)button
{
//    [UUProgressHUD changeSubTitle:@"手指上滑,取消发送"];
}

//计时器
- (void)countVoiceTime{
    playTime ++;
    if (playTime>=120) {
        //停止录制
        [self.audioRecorder stop];
        
    }else{
        [Tools makeTask:[NSString stringWithFormat:@"%ld",playTime] WithTime:1];
    }
}

//代理方法
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)flag{
    if (flag) {
        [Tools makeTask:@"录制完成" WithTime:2];
    }
   
}



@end
