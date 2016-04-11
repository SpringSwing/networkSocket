//
//  ViewController.m
//  networkSocket
//
//  Created by SHF on 16/3/29.
//  Copyright © 2016年 SHF. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "udpSocket.h"
#define kServerIP

@interface ViewController ()
{
    CGFloat realHeight;
    CGFloat realBottom;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *padBottom;
@property (strong, nonatomic) IBOutlet UIView *padview;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) GCDAsyncSocket* socket;
@property (strong,nonatomic) GCDAsyncUdpSocket* msgSocket;
@property (strong,nonatomic) FMDatabase *db;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    realHeight = _tableHeight.constant;
    realBottom = _padBottom.constant;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldUpdate:) name:@"shouldUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.navigationItem.title = _to;
    _chatArr = [[NSMutableArray alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource=self;
    _tableView.allowsSelection = NO;


    _msgSocket = [udpSocket sharedInstance];
    UITapGestureRecognizer* hideKeyBoard = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [_tableView addGestureRecognizer:hideKeyBoard];
    
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbname = [NSString stringWithFormat:@"/%@.sqlite",_from];
    path = [path stringByAppendingString:dbname];
    _db = [FMDatabase databaseWithPath:path];
    if([_db open])
    {

        NSString* fetch = [NSString stringWithFormat: @"select * from %@_%@ order by time asc;",_from,_to];
       FMResultSet* set =  [_db executeQuery:fetch];
        while ([set next]) {
            NSString* time = [set stringForColumn:@"time"];
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate* date = [formatter dateFromString:time];
            NSString* me = [set stringForColumn:@"me"];
            NSString* friend = [set stringForColumn:@"friend"];
            NSString* content = [set stringForColumn:@"content"];
            messageData* da = [[messageData alloc]initWithO:me andContent:content];

            [_chatArr addObject:da];
        }

  
        [_db close];
    }
    else
    {
        NSLog(@"数据库开启失败");
    }
}

-(void) viewDidLayoutSubviews
{
    if(_chatArr.count != 0)
    {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (IBAction)sendMsg:(id)sender {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* date = [formatter stringFromDate:[NSDate date] ];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:_from forKey:@"from"];
    [dic setValue:_to forKey:@"to"];
    [dic setValue:_textField.text forKey:@"content"];
    [dic setValue:date forKey:@"date"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    
    
    NSInteger remoteUdpPort = [[[NSUserDefaults standardUserDefaults]valueForKey:@"remoteUdpPort"] integerValue];
    [_msgSocket sendData:jsonData toHost:@"169.254.58.54" port:remoteUdpPort withTimeout:-1 tag:1];
    
    messageData* da = [[messageData alloc]initWithO:_from andContent:_textField.text];
    [_chatArr addObject:da];
    NSIndexPath* index = [NSIndexPath indexPathForRow:_chatArr.count-1 inSection:0];
    [_tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationBottom];
    
    [_tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString* dbname = [NSString stringWithFormat:@"/%@.sqlite",_from];
    path = [path stringByAppendingString:dbname];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
    
    NSString* sql =
   [NSString stringWithFormat:@"insert into %@_%@ (time,me,friend,content) values (?, ?, ?, ?);",_from,_to];
    
    [_db executeUpdate:sql, date,_from,_to,_textField.text];
    [_db close];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}




#pragma mark - UITableViewDelegate AND DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chatArr.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    
    
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    messageData* data = _chatArr[indexPath.row];
    
    NSString* str;
   // NSLog(@"%@,%@",data.toName,_from );
    if([data.toName isEqualToString:_from])
    {
        sendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sendCell" forIndexPath:indexPath];

    //    cell.message.numberOfLines = 0;
        cell.message.lineBreakMode = NSLineBreakByWordWrapping ;
        cell.message.text = data.content ;
        UIFont *font = [UIFont systemFontOfSize:14.];
        CGSize size = [data.content sizeWithFont:font constrainedToSize:CGSizeMake(300.0f, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
        
        if (size.height < 21) {
            cell.message.textAlignment = NSTextAlignmentRight;
        }
        
        return cell;
    }
    else
    {
        reciveCell* cell = [tableView dequeueReusableCellWithIdentifier:@"reciveCell" forIndexPath:indexPath];

        str = [NSString stringWithFormat:@"%@:%@",data.toName,data.content];
      //  cell.message.numberOfLines = 0;
        cell.message.lineBreakMode = NSLineBreakByWordWrapping ;
        cell.message.text = data.content ;
//        UIFont *font = [UIFont systemFontOfSize:14.];
//        CGSize size = [data.content sizeWithFont:font constrainedToSize:CGSizeMake(300.0f, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
        
        
        return cell;
    }
    
}

#pragma mark - NotificationCenter
-(void) shouldUpdate:(NSNotification*)notification
{
    NSDictionary* dic = notification.userInfo;
    NSString* content = [dic valueForKey:@"content"];
    NSString* from    = [dic valueForKey:@"from"];
    NSString* to      = [dic valueForKey:@"to"];
    NSString* dateTmp    = [dic valueForKey:@"date"];
    
    if ([from isEqualToString:_to]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            messageData* da = [[messageData alloc]initWithO:from andContent:content];
            [_chatArr addObject:da];
            NSIndexPath* index = [NSIndexPath indexPathForRow:_chatArr.count-1 inSection:0];
            [_tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            [_tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }) ;
    }
}
-(void)keyboardWillShow:(NSNotification*)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSIndexPath* index = [NSIndexPath indexPathForRow:_chatArr.count-1 inSection:0];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    UIViewAnimationOptions options = animationCurve << 16;

     [UIView animateWithDuration:animationDuration delay:0 options:options animations:^{
         _tableHeight.constant= _tableHeight.constant + keyboardSize.height;
         [_tableView layoutIfNeeded];
         _padBottom.constant = _padBottom.constant   + keyboardSize.height;
         [_padview layoutIfNeeded];
     } completion:^(BOOL finished) {
         if(_chatArr.count!=0)
         {
            [_tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
         }
     }];
    
}
-(void)keyboardWillHide:(NSNotification*)notification
{
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    UIViewAnimationOptions options = animationCurve << 16;

    [UIView animateWithDuration:animationDuration delay:0 options:options animations:^{
        _tableHeight.constant = realHeight;
        [_tableView layoutIfNeeded];
        _padBottom.constant =realBottom;
        [_padview layoutIfNeeded];
    } completion:^(BOOL finished) {
      
    }];
}
- (void)hideKeyboard
{
    if([_textField isFirstResponder])
    {
        [_textField resignFirstResponder];
    }
}
@end
