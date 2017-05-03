//
//  NSTObject.h
//  speedtest
//
//  Created by Vladislav Dugnist on 4/18/17.
//  Copyright © 2017 vdugnist. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NSTConnectionType) {
    NSTConnectionTypeWiFi,
    NSTConnectionTypeWWAN,
};

@interface NSTObject : NSObject

@property (nonatomic) NSTConnectionType connectionType;
@property (nonatomic) NSTimeInterval beginTimestamp;
@property (nonatomic) NSTimeInterval endTimestamp;
@property (nonatomic) uint32_t bytesCount;
@property (nonatomic) uint32_t packetsCount;

@end

NS_ASSUME_NONNULL_END
