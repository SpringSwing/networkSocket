//
//  messageData.h
//  networkSocket
//
//  Created by SHF on 16/3/31.
//  Copyright © 2016年 SHF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface messageData : NSObject
@property (copy,nonatomic) NSString* toName;
@property (copy,nonatomic) NSString* content;
-(id)initWithO:(NSString*)toName andContent:(NSString*)content;
@end