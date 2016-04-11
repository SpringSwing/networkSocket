//
//  udpSocket.m
//  networkSocket
//
//  Created by SHF on 16/4/3.
//  Copyright © 2016年 SHF. All rights reserved.
//

#import "udpSocket.h"
static GCDAsyncUdpSocket* sock = nil;
@implementation udpSocket
+(GCDAsyncUdpSocket*) sharedInstance
{
    @synchronized (self) {
        if (sock == nil) {
            dispatch_queue_t q= dispatch_queue_create("udp", DISPATCH_QUEUE_SERIAL);
            sock = [[GCDAsyncUdpSocket alloc]initWithDelegate:nil delegateQueue:q];
            
        }
    }
    return sock;
}
+(void)sDelegate:(id) del
{
    sock.delegate = del;
    int a =  [sock bindToPort:30000 error:nil];
    int b =  [sock beginReceiving:nil];
    int c =  [sock enableBroadcast:YES error:nil];


}
@end
