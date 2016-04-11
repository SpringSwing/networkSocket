//
//  ViewController.h
//  networkSocket
//
//  Created by SHF on 16/3/29.
//  Copyright © 2016年 SHF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messageData.h"
#import "GCDAsyncUdpSocket.h"
#import "sendCell.h"
#import "reciveCell.h"

@interface ViewController : UIViewController<GCDAsyncUdpSocketDelegate,UITableViewDelegate,UITableViewDataSource>
@property (copy,nonatomic) NSString* from;
@property (copy,nonatomic) NSString* to;
@property (strong,nonatomic) NSMutableArray* chatArr;

@end

