//
//  TimeLineTableViewController.m
//  TwitterClient01
//
//  Created by g-2016 on 2015/01/18.
//  Copyright (c) 2015年 aki120121. All rights reserved.
//

#import "TimeLineTableViewController.h"

@interface TimeLineTableViewController ()
@property dispatch_queue_t mainQueue;
@property dispatch_queue_t imageQueue;
@property NSString *httpErrorMessage;
@property NSArray *timeLineDate;


@end

@implementation TimeLineTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.mainQueue = dispatch_get_main_queue();
    self.imageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    [self.tableView registerClass:[TimeLineCell class] forCellReuseIdentifier:@"TimeLineCell"];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];  //タイムライン取得のURL
    NSDictionary *params = @{@"count" : @"100",                 // 何件データを持ってくるか デフォルトは20件
                             @"trim_user" : @"0",
                             @"include_entities" : @"0"};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter   // Twitter
                                            requestMethod:SLRequestMethodGET    // メソッドはGET
                                                      URL:url                   // URLセット
                                               parameters:params];              // パラメタセット
    request.account = account;
    NSLog(@"%@",request.URL);
    
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;  // インジケータON
    
    [request performRequestWithHandler:^(NSData *responseDate,
                                         NSHTTPURLResponse *urlResponse,
                                         NSError *error) {
        if(responseDate){
            self.httpErrorMessage = nil;
            if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {    // 200番台は成功
                NSError *jsonError;
                self.timeLineDate = [NSJSONSerialization JSONObjectWithData:responseDate            // 複数件のNSDictionaryが返される
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&jsonError];
                if (self.timeLineDate) {
                    NSLog(@"Timeline Response: %@\n", self.timeLineDate);
                    dispatch_async(self.mainQueue, ^{  // UI処理はメインキューで
                        [self.tableView reloadData];            //テーブルビュー書き換え
                    });
                } else {  // JSONシリアライズエラー発生時
                    NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                }
            } else {  //HTTPエラー発生時
                self.httpErrorMessage = [NSString stringWithFormat:@"The response status code is %ld",urlResponse.statusCode];
                NSLog(@"HTTP Error: %@", self.httpErrorMessage);
                dispatch_async(self.mainQueue, ^{ // UI処理はメインキューで
                    [self.tableView reloadData];            // テーブルビュー書き換え
                });
            }
        } else { //リクエスト送信エラー発生時
            NSLog(@"ERROR: An error occurredwhile requesting: %@", [error localizedDescription]);
              // リクエスト時の送信エラーメッセージを画面に表示する領域がない。今後の課題
        }
        dispatch_async(self.mainQueue, ^{
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;  //インジケータOFF
        });
    }];
}

- (NSAttributedString *)labelattributedString:(NSString *)labelString
{
    // ラベル文字列
    NSString *text = (labelString == nil) ? @"" : labelString;
    // フォントの指定
    UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13];
    // カスタムLineHeiguhtを指定
    CGFloat customLineHeight = 19.5f;
    // パラグラフスタイルにlineHeightをセット
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = customLineHeight;
    paragraphStyle.maximumLineHeight = customLineHeight;
    // 属性としてパラグラフスタイルとフォントをセット
    NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraphStyle,
                                 NSFontAttributeName:font};
    // NSAttributedStringを生成して文字列と属性をセット
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    return attributedText;
}

- (CGFloat)labelHeight:(NSAttributedString *)attributedText // 属性付きテキストからラベルの高さを求める
{
    // ラベルの高さを計算
    CGFloat aHeight = [attributedText boundingRectWithSize:CGSizeMake(257, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil].size.height;
    return aHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(!self.timeLineDate){
        return 1;
    } else {
        return [self.timeLineDate count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeLineCell"forIndexPath:indexPath];
    // Configure the cell...
    if (self.httpErrorMessage) {
        cell.tweetTextLabel.text = @"HTTP Error!";
        cell.tweetTextLabelHeight = 24.0;
    } else if (!self.timeLineDate){
        cell.tweetTextLabel.text = @"Loading...";
        cell.tweetTextLabelHeight = 24.0;
    } else {
        NSString *tweetText = self.timeLineDate[indexPath.row][@"text"];
        NSAttributedString *attributedTweetText = [self labelattributedString:tweetText];
        // ツイート本文を属性付きテキストに変換して表示
        
        cell.tweetTextLabel.attributedText = attributedTweetText;
        cell.nameLabel.text = self.timeLineDate[indexPath.row][@"user"][@"screen_name"];
        cell.profileImageView.image = [UIImage imageNamed:@"black.png"];
        cell.tweetTextLabelHeight = [self labelHeight:attributedTweetText];
        
        // ラベルの高さを計算
        dispatch_async(self.imageQueue, ^{
            NSString *url;
            NSDictionary *tweetDictionary = [self.timeLineDate objectAtIndex:indexPath.row];
            if ([[tweetDictionary allKeys] containsObject:@"retweeted_status"]) {
                // リツイートの場合はretweeted_statusキー項目が存在する
                url = tweetDictionary[@"retweeted_status"][@"user"][@"profile_image_url"];
                // リツイート元のユーザのプロフィール画像URLを取得
            } else {
                url = tweetDictionary[@"user"][@"profile_image_url"];
                // 通常は発言者のプロフィール画像を取得
            }
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            // プロフィール画像の取得
            dispatch_async(self.mainQueue, ^{
                UIApplication *application = [UIApplication sharedApplication];
                application.networkActivityIndicatorVisible = NO;
                UIImage *image = [[UIImage alloc] initWithData:data];
                cell.profileImageView.image = image;
                [cell setNeedsLayout];  //セル書き換え
            });
        });
                                                                        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tweetText = self.timeLineDate[indexPath.row][@"text"];
    NSAttributedString *attributedTweetText = [self labelattributedString:tweetText];
    CGFloat tweetTextLabelHeght = [self labelHeight:attributedTweetText];
    
    return tweetTextLabelHeght + 35;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeLineCell *cell = (TimeLineCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailViewController.text = cell.tweetTextLabel.text;
    detailViewController.name = cell.nameLabel.text;
    detailViewController.image = cell.profileImageView.image;
    detailViewController.identifier = self.identifier;
    detailViewController.idStr = self.timeLineDate[indexPath.row][@"id_str"];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
