//
//  messageData.m
//  networkSocket
//
//  Created by SHF on 16/3/31.
//  Copyright © 2016年 SHF. All rights reserved.
//

#import "messageData.h"

@implementation messageData
-(id)initWithO:(NSString*)toName andContent:(NSString*)content
{
    if(self = [super init])
    {
        self.toName = toName;
        self.content = content;
    }
    return self;
}
@end
