//
//  chatToolBar.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/9.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "chatToolBar.h"
#import "RecordAudio.h"
#import "WHProgressHUD.h"

#define RECT_CHANGE_x(v,x)          CGRectMake(x, Y(v), WIDTH(v), HEIGHT(v))
#define RECT_CHANGE_y(v,y)          CGRectMake(X(v), y, WIDTH(v), HEIGHT(v))
#define RECT_CHANGE_point(v,x,y)    CGRectMake(x, y, WIDTH(v), HEIGHT(v))
#define RECT_CHANGE_width(v,w)      CGRectMake(X(v), Y(v), w, HEIGHT(v))
#define RECT_CHANGE_height(v,h)     CGRectMake(X(v), Y(v), WIDTH(v), h)
#define RECT_CHANGE_size(v,w,h)     CGRectMake(X(v), Y(v), w, h)

#define kToolBarH 45
#define kTextFieldH 32

@interface chatToolBar ()<RecordAudioDelegate>
{
    BOOL isbeginVoiceRecord;
    RecordAudio *recordAudio;
    BOOL isRecording;
    NSData *curAudio;
    
    BOOL isfromLibray;//从相册返回

    NSInteger playTime;
    NSTimer *playTimer;
}
@end

static double startRecordTime=0;
static double endRecordTime=0;

@implementation chatToolBar

- (id)initWithSuperVC:(UIViewController *)superVC
{
    self.superVC = superVC;
    CGRect frame = CGRectMake(0, ViewHeight-45-66+3, ViewWidth, 45);
    
    self = [super initWithFrame:frame];
    if (self) {
        //初始化录音机
        recordAudio = [[RecordAudio alloc]init];
        recordAudio.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
        //发送消息
        self.btnSendMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnSendMessage.frame =CGRectMake(ViewWidth-24-10, 10, 24, 24);;
        self.isAbleToSendTextMessage = NO;
        [self.btnSendMessage setImage:[UIImage imageNamed:@"using_photo"] forState:UIControlStateNormal];
        [self.btnSendMessage addTarget:self action:@selector(presstoSendImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnSendMessage];
        
        //改变状态（语音、文字）
        //change输入模式的button
        UIButton *styleChangeButton=[UIButton buttonWithType:UIButtonTypeCustom];
        styleChangeButton.frame=CGRectMake(10, 10, 24, 24);
        [styleChangeButton setImage:[UIImage imageNamed:@"using_voice"] forState:UIControlStateNormal];
        [styleChangeButton setImage:[UIImage imageNamed:@"using_keyboard"] forState:UIControlStateSelected];
        [styleChangeButton addTarget:self action:@selector(styleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:styleChangeButton];
        
        //输入框
        self.TextViewInput = [[UITextField alloc] init];
        self.TextViewInput.borderStyle=UITextBorderStyleRoundedRect;
        self.TextViewInput.returnKeyType = UIReturnKeySend;
        self.TextViewInput.enablesReturnKeyAutomatically = YES;
        self.TextViewInput.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 1)];
        self.TextViewInput.leftViewMode = UITextFieldViewModeAlways;
        self.TextViewInput.frame = CGRectMake(44, 6, ViewWidth-2*44, kTextFieldH);
        self.TextViewInput.backgroundColor = [UIColor whiteColor];
        self.TextViewInput.delegate = self;
        [self addSubview:self.TextViewInput];

        
        //语音录入键
        self.btnVoiceRecord = [[UIButton alloc] initWithFrame:self.TextViewInput.frame];
        self.btnVoiceRecord .titleLabel.font =YiZhenFont14;
        self.btnVoiceRecord.layer.cornerRadius=4;
        self.btnVoiceRecord .layer.masksToBounds=YES;
        [self.btnVoiceRecord  setTitleColor:grayLabelColor forState:UIControlStateNormal];
        [self.btnVoiceRecord  setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
        [self.btnVoiceRecord  setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordSelectedBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
        [self.btnVoiceRecord  setTitle:@"按住说话" forState:UIControlStateNormal];
        [self.btnVoiceRecord  setTitle:@"松开发送" forState:UIControlStateHighlighted];
        [self.btnVoiceRecord addTarget:self action:@selector(beginRecordVoice:) forControlEvents:UIControlEventTouchDown];
        [self.btnVoiceRecord addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnVoiceRecord addTarget:self action:@selector(cancelRecordVoice:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [self.btnVoiceRecord addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
        [self.btnVoiceRecord addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        self.btnVoiceRecord.hidden=YES;
        [self addSubview:self.btnVoiceRecord];
    }
    return self;
}

#pragma mark - 录音touch事件
- (void)beginRecordVoice:(UIButton *)button
{
    [recordAudio stopPlay];
    [recordAudio startRecord];
    startRecordTime = [NSDate timeIntervalSinceReferenceDate];
    [WHProgressHUD show];
}

- (void)endRecordVoice:(UIButton *)button
{
    NSURL *url = [recordAudio stopRecord];
    endRecordTime = [NSDate timeIntervalSinceReferenceDate];
    endRecordTime -= startRecordTime;
    if (endRecordTime<2.00f) {
        [WHProgressHUD dismissWithSuccess:@"录音时间太短"];
        return;
    }
    
    if (url != nil) {
        curAudio = EncodeWAVEToAMR([NSData dataWithContentsOfURL:url],1,16);
        if (curAudio) {
            [self.delegate InputFunctionView:self sendVoice:curAudio time:endRecordTime];
            [WHProgressHUD dismissWithSuccess:@"已发送"];
        }
    }
}

- (void)cancelRecordVoice:(UIButton *)button
{
    [recordAudio stopRecord];
    [WHProgressHUD dismissWithError:NSLocalizedString(@"撤回", @"")];
}

- (void)RemindDragExit:(UIButton *)button
{
    [WHProgressHUD changeSubTitle:NSLocalizedString(@"松开撤回", @"")];
}

- (void)RemindDragEnter:(UIButton *)button
{
    [WHProgressHUD changeSubTitle:NSLocalizedString(@"拉起撤回", @"")];
}

#pragma mark-改变输入状态
-(void)styleButtonAction:(UIButton*)button
{
    button.selected = !button.selected;
    if (button.selected) {
        self.TextViewInput.text = @"";
        [self.TextViewInput resignFirstResponder];
    }
    else{
        [self.TextViewInput becomeFirstResponder];
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.btnVoiceRecord.hidden = !button.selected;
        self.TextViewInput.hidden = button.selected;
    } completion:nil];
}

-(void)presstoSendImage
{
    [self.TextViewInput resignFirstResponder];
    UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"相机", @""),NSLocalizedString(@"相册", @""),nil];
    [actionSheet showInView:self.window];
}


-(void)RecordStatus:(int)status {
    if (status==0){
        //播放中
    } else if(status==1){
        //完成
        NSLog(@"播放完成");
    }else if(status==2){
        //出错
        NSLog(@"播放出错");
    }
}
#pragma mark - textFeild的delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.delegate InputFunctionView:self sendMessage:textField.text];
    return YES;
}

#pragma mark - Add Picture
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self addCarema];
    }else if (buttonIndex == 1){
        [self openPicLibrary];
    }
}

-(void)addCarema{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.superVC presentViewController:picker animated:YES completion:^{}];
    }else{
        //如果没有提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", @"") message:NSLocalizedString(@"您的设备没有照相机", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", @"") otherButtonTitles:nil];
        [alert show];
    }
}

-(void)openPicLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.navigationBar.tintColor=themeColor;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        isfromLibray=YES;
        [self.superVC presentViewController:picker animated:YES completion:^{
        }];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
            [self.superVC dismissViewControllerAnimated:YES completion:^{
                [self.delegate InputFunctionView:self sendPicture:image andFromLibrary:isfromLibray];
                isfromLibray=NO;
            }];
        });
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.superVC dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
