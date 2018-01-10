//
//  chatToolBar.h
//  yizhenDoctor
//
//  Created by augbase on 16/9/9.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import <UIKit/UIKit.h>

@class chatToolBar;

@protocol chatToolBarDelegate <NSObject>
// text
- (void)InputFunctionView:(chatToolBar *)funcView sendMessage:(NSString *)message;

// image
- (void)InputFunctionView:(chatToolBar *)funcView sendPicture:(UIImage *)image andFromLibrary:(BOOL)fromLibrary;

// voice
- (void)InputFunctionView:(chatToolBar *)funcView sendVoice:(NSData *)voice time:(NSInteger)second;

@end

@interface chatToolBar : UIView<UIImagePickerControllerDelegate,UINavigationBarDelegate,UIActionSheetDelegate,UITextFieldDelegate>

@property (nonatomic, retain) UIButton *btnSendMessage;
@property (nonatomic, retain) UIButton *btnChangeVoiceState;
@property (nonatomic, retain) UIButton *btnVoiceRecord;
@property (nonatomic, retain) UITextField *TextViewInput;

@property (nonatomic, assign) BOOL isAbleToSendTextMessage;

@property (nonatomic, retain) UIViewController *superVC;

@property (nonatomic, assign) id<chatToolBarDelegate>delegate;


- (id)initWithSuperVC:(UIViewController *)superVC;

@end
