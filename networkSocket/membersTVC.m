//
//  membersTVC.m
//  networkSocket
//
//  Created by SHF on 16/4/2.
//  Copyright © 2016年 SHF. All rights reserved.
//

#import "membersTVC.h"
#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "udpSocket.h"
@interface friendAndMsg : NSObject
@property(nonatomic,copy)   NSString* name;
@property(nonatomic,assign)   NSInteger unread ;
@end
@implementation friendAndMsg


@end


@interface membersTVC ()
@property (nonatomic,strong) NSMutableArray* friends;
@property (nonatomic,copy)   NSString* localName;
@property (nonatomic,strong) FMDatabase* db;
@property (weak,nonatomic)ViewController* chat;
@end

@implementation membersTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _friends = [[NSMutableArray alloc]init];
    [udpSocket sDelegate:self];
    _localName = [[NSUserDefaults standardUserDefaults]valueForKey:@"localName"];
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray* arr = [[NSArray arrayWithContentsOfFile:[path stringByAppendingString:[NSString stringWithFormat:@"/%@_.plist",_localName]]] mutableCopy];
    for (int i=0; i<arr.count; i++) {
        friendAndMsg *tmp = [[friendAndMsg alloc]init];
        tmp.name = arr[i];
        tmp.unread = 0;
        [_friends addObject:tmp];
    }
    
    self.navigationItem.title = _localName;
    
    
    
    /////////////////////////////////////////////////////////////////////
   
    NSString* dbname = [NSString stringWithFormat:@"/%@.sqlite",_localName];
    path = [path stringByAppendingString:dbname];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];

    for (int i=0; i<_friends.count; i++) {
        friendAndMsg* tmp = _friends[i];
        NSString* SQLcreate =
        [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@_%@(time text , me text , friend text , content text);",_localName,tmp.name];
          [_db executeUpdate:SQLcreate];
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return _friends.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memberCell" forIndexPath:indexPath];
    
    NSInteger i = indexPath.row;
    friendAndMsg* tmp = _friends[i];
    cell.textLabel.text = [NSString stringWithFormat:@"%@        %ld",tmp.name,(long)tmp.unread];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _chat = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"chat"];
    _chat.from = _localName;
    friendAndMsg* tmp = _friends[indexPath.row];
    _chat.to = tmp.name;
    tmp.unread = 0;
    [self.navigationController pushViewController:_chat animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}



#pragma mark - UDP message

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSString* content = [dic valueForKey:@"content"];
    NSString* from    = [dic valueForKey:@"from"];
    NSString* to      = [dic valueForKey:@"to"];
    NSString* dateTmp    = [dic valueForKey:@"date"];
    

    

    [_db open];

    NSString* sql =
    [NSString stringWithFormat:@"insert into %@_%@ (time,me,friend,content) values (?,?,?,?);",
     _localName,from];
    
    [_db executeUpdate:sql,dateTmp,from,to,content];
    [_db close];
    
    if(_chat == nil || (_chat != nil && ![_chat.to isEqualToString:from]))
    {
        for (int i=0; i<_friends.count; i++) {
            friendAndMsg* tmp = _friends[i];
            if ([tmp.name isEqualToString:from]) {
                tmp.unread ++;
            }
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
        }
        
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"shouldUpdate" object:nil userInfo:dic];
    
}
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    
}

@end
