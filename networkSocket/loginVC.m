//
//  loginVC.m
//  networkSocket
//
//  Created by SHF on 16/4/2.
//  Copyright © 2016年 SHF. All rights reserved.
//

#import "loginVC.h"
#define kUDP_PORT 30000

@interface loginVC ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *myId;
@property (assign,nonatomic) NSInteger index;
@property (strong,nonatomic) GCDAsyncSocket *socket;
@property (strong,nonatomic) GCDAsyncUdpSocket* udp;

@end

@implementation loginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (IBAction)login:(id)sender {
    _index = _myId.selectedSegmentIndex + 1;
    dispatch_queue_t q = dispatch_queue_create("socket", DISPATCH_QUEUE_SERIAL);
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:q];
    _socket.delegate = self;
    
    NSError* err;
    if([_socket connectToHost:@"169.254.58.54" onPort:10000 error:&err])
    {
        NSLog(@"TCP 连接成功");
    }
    else
    {
        NSLog(@"TCP 连接失败");
    }
    
    
}

#pragma mark -TCP delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    _udp = [udpSocket sharedInstance];
    
    NSString* name = [NSString stringWithFormat:@"%@ %d",[_myId titleForSegmentAtIndex:_index-1],kUDP_PORT];
    NSData* data = [name dataUsingEncoding:NSUTF8StringEncoding];
    [_socket readDataWithTimeout:-1 tag:1];
    [_socket writeData:data withTimeout:-1 tag:1];
}

//- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url
//{
//    
//}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString* str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableArray* friends = [[str componentsSeparatedByString:@"+"] mutableCopy];
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* name = [NSString stringWithFormat:@"%@",[_myId titleForSegmentAtIndex:_index-1]];
    NSInteger remoteUdpPort = [[friends lastObject] integerValue];
    [friends removeLastObject];
    [friends writeToFile:[path stringByAppendingString:[NSString stringWithFormat:@"/%@_.plist",name]]
              atomically:YES];
    
    NSLog(@"%@",path);
    [[NSUserDefaults standardUserDefaults] setValue:name
                                             forKey:@"localName"];
    
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithInteger:remoteUdpPort]
                                            forKey:@"remoteUdpPort"];
    
    
    UINavigationController* nav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"nav"];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    
}

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    
}

//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
//                 elapsed:(NSTimeInterval)elapsed
//               bytesDone:(NSUInteger)length
//{
//
//}

//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
//                 elapsed:(NSTimeInterval)elapsed
//               bytesDone:(NSUInteger)length
//{
//
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
