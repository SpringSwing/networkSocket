//
//  udpSocket.h
//  networkSocket
//
//  Created by SHF on 16/4/3.
//  Copyright © 2016年 SHF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
@interface udpSocket : NSObject

+(GCDAsyncUdpSocket*) sharedInstance;
+(void)sDelegate:(id) del;
@end
