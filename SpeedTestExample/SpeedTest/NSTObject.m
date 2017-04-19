//
//  NSTObject.m
//  speedtest
//
//  Created by Vladislav Dugnist on 4/18/17.
//  Copyright © 2017 vdugnist. All rights reserved.
//

#import "NSTObject.h"

@implementation NSTObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"%f sec: %u bytes;",
                     self.endTimestamp - self.beginTimestamp,
                     self.bytesCount];
}

@end
