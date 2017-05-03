//
//  NSTObject.m
//  speedtest
//
//  Created by Vladislav Dugnist on 4/18/17.
//  Copyright © 2017 vdugnist. All rights reserved.
//

#import "NSTObject.h"

@implementation NSTObject

NSString* connectionTypeDescription(NSTConnectionType type)
{
    switch (type) {
    case NSTConnectionTypeWiFi:
        return @"wifi";
    case NSTConnectionTypeWWAN:
        return @"wwan";
    }

    return nil;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"begin:%f duration:%.1f connectionType:%@ bytes:%u packets:%u",
                     self.beginTimestamp,
                     self.endTimestamp - self.beginTimestamp,
                     connectionTypeDescription(self.connectionType),
                     self.bytesCount,
                     self.packetsCount];
}

@end
