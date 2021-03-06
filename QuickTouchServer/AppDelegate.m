//
//  AppDelegate.m
//  QuickTouchServer
//
//  Created by TsuiYuenHong on 2016/11/7.
//  Copyright © 2016年 TsuiYuenHong. All rights reserved.
//

#import "AppDelegate.h"
#import "QRCodeCreator.h"
#import "QTProcessor.h"

#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSImageView *qrCodeImage;
@property (weak) IBOutlet NSTextField *ipAddressLabel;
@property (weak) IBOutlet NSTextField *sendPortLabel;
@property (weak) IBOutlet NSTextField *receivePortLabel;
@property (weak) IBOutlet NSTextField *iOSIPInfosLabel;

@property (strong) QTProcessor *qtProcessor;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    if ([[NSUserDefaults standardUserDefaults] objectForKey:UserDeafault_iOSLocalIP]) {
        [QTProcessor sharedInstance].host = [[NSUserDefaults standardUserDefaults] objectForKey:UserDeafault_iOSLocalIP];
        self.iOSIPInfosLabel.stringValue = [NSString stringWithFormat:@"iOS IP:%@ Send:%d Rece:%d",[QTProcessor sharedInstance].host,QTRECEIVEPORT,QTSENDPORT];
    }
    
    [QTProcessor sharedInstance].recePort = QTRECEIVEPORT;
    [QTProcessor sharedInstance].sendPort = QTSENDPORT;
    [[QTProcessor sharedInstance] beginReceiving];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(sendMacInfos) name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(reloadMainView) name:QTServerMainViewReload object:nil];
    
    [self configSubviews];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)reloadMainView{
    [QTProcessor sharedInstance].host = [[NSUserDefaults standardUserDefaults] objectForKey:UserDeafault_iOSLocalIP];
    self.iOSIPInfosLabel.stringValue = [NSString stringWithFormat:@"iOS IP:%@ Send:%d Rece:%d",[QTProcessor sharedInstance].host,QTRECEIVEPORT,QTSENDPORT];
}

#pragma mark - Config Subviews
- (void)configSubviews{
    self.ipAddressLabel.stringValue = [NSString stringWithFormat:@"Local IP : %@",[QTSystemSetting getLocalIPAddress]];
    self.sendPortLabel.stringValue = [NSString stringWithFormat:@"Send Port : %d",QTSENDPORT];
    self.receivePortLabel.stringValue = [NSString stringWithFormat:@"Rece Port : %d",QTRECEIVEPORT];
    NSString *qrString = [NSString stringWithFormat:@"%@/%d/%d",[QTSystemSetting getLocalIPAddress],QTRECEIVEPORT,QTSENDPORT];
    self.qrCodeImage.image = [QRCodeCreator qrImageForString:qrString imageSize:150];
}

#pragma mark - Send Mac Infos
- (void)sendMacInfos{
    QTMacToiOSModel *qtMacToiOSModel = [QTMacToiOSModel new];
    qtMacToiOSModel.type = QTMacToiOSFrontmostApp;
    qtMacToiOSModel.frontmostApp = [NSWorkspace sharedWorkspace].frontmostApplication.localizedName;
    QTTypeModel *qtTypeModel = [QTTypeModel new];
    qtTypeModel.qtDesc = @"发送 Mac 系统信息";
    qtTypeModel.qtType = QTMacToiOS;
    qtTypeModel.qtContent = qtMacToiOSModel;
    [[QTProcessor sharedInstance] sendQTTypeModel:qtTypeModel];
}
- (void)dealloc{
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

@end
