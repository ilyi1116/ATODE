//
//  ATDSettingViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/12.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDSettingViewController.h"
#import "ATDCoreDataManger.h"
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ATDSettingViewController ()
<UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation ATDSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark -
#pragma mark IBAction

- (IBAction)closeBtnTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark UITableViewDelegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    else if (section == 1) {
        return 1;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"メモの管理";
    }
    else if (section == 0) {
        return @"このアプリについて";
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeleteCell"];
        return cell;
    }
    else if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IndicatorCell"];
        switch (indexPath.row) {
            case kSettingCellTypeRequest:
                cell.textLabel.text = @"ご意見・ご要望";
                break;
            case kSettingCellTypeIntroduce:
                cell.textLabel.text = @"このアプリを友達に紹介する";
                break;
            case kSettingCellTypeReview:
                cell.textLabel.text = @"アプリのレビューを書く";
                break;
            case kSettingCellTypeLicense:
                cell.textLabel.text = @"ソフトウェア・ライセンス";
                break;
            case kSettingCellTypeVersion:
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
                cell.textLabel.text = @"アプリのバージョン";
                cell.detailTextLabel.text = [self _appVersion];
                return cell;
            }
        }
        return cell;
    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            // データ削除
            [UIActionSheet showInView:self.view
                            withTitle:@"削除したデータは元に戻せません。よろしいですか？"
                    cancelButtonTitle:@"キャンセル"
               destructiveButtonTitle:@"データをすべて削除する"
                    otherButtonTitles:nil
                             tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                 if (actionSheet.cancelButtonIndex != buttonIndex) {
                                     [self resetMemoData];
                                 }
                             }];
        }
    }
    else if (indexPath.section == 0) {
        switch (indexPath.row) {
            case kSettingCellTypeIntroduce:
                // 友達に紹介する(Tw / Fb)
                break;
            case kSettingCellTypeRequest:
                // ご意見・ご要望（メール or Tw）
                [self launchMail];
                break;
            case kSettingCellTypeReview:
            {
                // レビュー
                [[UIApplication sharedApplication]
                 openURL:[NSURL URLWithString:@"http://itunes.apple.com/ja/app/id669050459?mt=8"]];
                break;
            }

            case kSettingCellTypeLicense:
                // ライセンス
                break;
        }
    }
}



- (void)resetMemoData {
    [[ATDCoreDataManger sharedInstance] resetSaveData];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"データを削除しました"
                                                     message:@""
                                                    delegate:nil
                                           cancelButtonTitle:nil otherButtonTitles:@"OK", nil
                           ];
    [alert show];
}



#pragma mark -

/*
 * アプリ内でメールを立ち上げる
 */
-(void)launchMail
{
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[NSArray arrayWithObject:SUPPORT_MAIL_ADDRESS]];
        mailViewController.title = @"";
        [mailViewController setSubject:@"【Manifesto】お問い合わせ"];
        
        // マーケットに出ている場合
        NSString *body = @"【お問い合わせ内容】\n\n\n\n※以下は変更しないで下さい。\n-----\nDEVICE: %@\niOS: %@\nVERSION: %@\n";
        [mailViewController setMessageBody:[NSString stringWithFormat:body,[UIDevice currentDevice].systemVersion, [self _platformString],[self _appVersion]] isHTML:NO];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    
    else {
        UIAlertView *mailBoxAlert = [[UIAlertView alloc] initWithTitle:@"メール設定エラー"
                                                               message:@"端末にメールアカウント設定を行ってください。"
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles: nil];
        [mailBoxAlert show];
    }
}

- (NSString*)_appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString *) _platform
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = 6;
    mib[1] = 1;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

- (NSString *) _platformString
{
    NSString *platform = [self _platform];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPod1,1"])  return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])  return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])  return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])  return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])  return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])  return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])  return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])  return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])  return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,5"])  return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])  return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])  return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])  return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])  return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,3"])  return @"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])  return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])  return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad4,3"])  return @"iPad 4 (CDMA)";
    if ([platform isEqualToString:@"i386"])   return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])  return @"iPhone Simulator";
    return platform;
}


/*
 * メール画面の「閉じる」ボタンを押したらメール画面を消す
 */
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
