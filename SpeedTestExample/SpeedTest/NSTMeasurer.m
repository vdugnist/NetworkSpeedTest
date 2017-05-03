//
//  NSTMeasurer.m
//  speedtest
//
//  Created by Vladislav Dugnist on 4/18/17.
//  Copyright © 2017 vdugnist. All rights reserved.
//

// <net/if.h> must be included before <iffaddrs.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "NSTMeasurer.h"
#import "NSTObject.h"
#import <UIKit/UIKit.h>

static NSTimeInterval const kDefaultMeasureInterval = 0.5;
static NSUInteger const kMaxDataCount = 3600;

@interface NSTMeasurer ()

@property (nonatomic) NSTimer* collectingTimer;
@property (nonatomic) NSMutableArray<NSTObject*>* collectedData;
@property (nonatomic) uint32_t previousWifiBytesCount;
@property (nonatomic) uint32_t previousWwanBytesCount;
@property (nonatomic) uint32_t previousWifiPacketsCount;
@property (nonatomic) uint32_t previousWwanPacketsCount;

@end

@implementation NSTMeasurer

- (instancetype)init
{
    if (self = [super init]) {
        _measureInterval = kDefaultMeasureInterval;
        _collectedData = [NSMutableArray new];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification* _Nonnull note) {
                                                          [self startCollectingData];
                                                      }];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification* _Nonnull note) {
                                                          [self stopCollectingData];
                                                      }];
        [self startCollectingData];
    }

    return self;
}

+ (NSSet<NSString*>*)keyPathsForValuesAffectingValueForKey:(NSString*)key
{
    NSSet<NSString*>* keyPaths = @{
        NSStringFromSelector(@selector(maxDownloadSpeed)) : [NSSet setWithObject:NSStringFromSelector(@selector(collectedData))],
        NSStringFromSelector(@selector(averageDownloadSpeed)) : [NSSet setWithObject:NSStringFromSelector(@selector(collectedData))],
        NSStringFromSelector(@selector(currentDownloadSpeed)) : [NSSet setWithObject:NSStringFromSelector(@selector(collectedData))],
    }[key];
    return keyPaths ?: [super keyPathsForValuesAffectingValueForKey:key];
}

- (void)setMeasureInterval:(NSTimeInterval)measureInterval
{
    assert(measureInterval > 0);
    _measureInterval = measureInterval;
}

- (void)startCollectingData
{
    if (self.collectingTimer) {
        [self stopCollectingData];
    }

    [self resetStartValues];
    self.collectingTimer = [NSTimer scheduledTimerWithTimeInterval:self.measureInterval
                                                            target:self
                                                          selector:@selector(collectData)
                                                          userInfo:nil
                                                           repeats:YES];
}

- (void)stopCollectingData
{
    [self.collectingTimer invalidate];
    self.collectingTimer = nil;
}

- (void)resetStartValues
{
    NSDictionary* currentInfo = [self currentInterfaceBytesCount];
    self.previousWifiBytesCount = (uint32_t)[currentInfo[@(NSTConnectionTypeWiFi)][0] unsignedIntegerValue];
    self.previousWwanBytesCount = (uint32_t)[currentInfo[@(NSTConnectionTypeWWAN)][0] unsignedIntegerValue];
    self.previousWifiPacketsCount = (uint32_t)[currentInfo[@(NSTConnectionTypeWiFi)][1] unsignedIntegerValue];
    self.previousWwanPacketsCount = (uint32_t)[currentInfo[@(NSTConnectionTypeWWAN)][1] unsignedIntegerValue];
}

- (void)collectData
{
    NSDictionary* currentInfo = [self currentInterfaceBytesCount];

    uint32_t wifiBytesCount = (uint32_t)[currentInfo[@(NSTConnectionTypeWiFi)][0] unsignedIntegerValue];
    uint32_t wwanBytesCount = (uint32_t)[currentInfo[@(NSTConnectionTypeWWAN)][0] unsignedIntegerValue];
    uint32_t wifiPacketsCount = (uint32_t)[currentInfo[@(NSTConnectionTypeWiFi)][1] unsignedIntegerValue];
    uint32_t wwanPacketsCount = (uint32_t)[currentInfo[@(NSTConnectionTypeWWAN)][1] unsignedIntegerValue];

    uint32_t wifiBytesCountDiff = wifiBytesCount - self.previousWifiBytesCount;
    uint32_t wwanBytesCountDiff = wwanBytesCount - self.previousWwanBytesCount;
    uint32_t wifiPacketsCountDiff = wifiPacketsCount - self.previousWifiPacketsCount;
    uint32_t wwanPacketsCountDiff = wwanPacketsCount - self.previousWwanPacketsCount;

    self.previousWifiBytesCount = wifiBytesCount;
    self.previousWwanBytesCount = wwanBytesCount;
    self.previousWifiPacketsCount = wifiPacketsCount;
    self.previousWwanPacketsCount = wwanPacketsCount;

    [self recordBytesCount:wifiBytesCountDiff packetsCount:wifiPacketsCountDiff forConnectionType:NSTConnectionTypeWiFi];
    [self recordBytesCount:wwanBytesCountDiff packetsCount:wwanPacketsCountDiff forConnectionType:NSTConnectionTypeWWAN];
}

- (NSDictionary*)currentInterfaceBytesCount
{
    struct ifaddrs* addrs;
    const struct ifaddrs* cursor;

    uint32_t wifiBytesCount = 0;
    uint32_t wwanBytesCount = 0;
    uint32_t wifiPacketsCount = 0;
    uint32_t wwanPacketsCount = 0;

    if (getifaddrs(&addrs) == 0) {
        cursor = addrs;

        while (cursor != NULL) {
            const struct if_data* ifa_data = (struct if_data*)cursor->ifa_data;

            if (ifa_data != NULL) {
                const uint32_t bytesCount = ifa_data->ifi_ibytes;
                const uint32_t packetsCount = ifa_data->ifi_ipackets;

                NSString* interfaceName = [NSString stringWithCString:cursor->ifa_name encoding:NSUTF8StringEncoding];
                NSString* const kWifiPrefix = @"en";
                NSString* const kVWANPrefix = @"pdp_ip";

                if ([interfaceName hasPrefix:kWifiPrefix]) {
                    wifiBytesCount += bytesCount;
                    wifiPacketsCount += packetsCount;
                }
                else if ([interfaceName hasPrefix:kVWANPrefix]) {
                    wwanBytesCount += bytesCount;
                    wwanPacketsCount += packetsCount;
                }
            }

            cursor = cursor->ifa_next;
        }
    }

    freeifaddrs(addrs);

    return @{
        @(NSTConnectionTypeWiFi) : @[ @(wifiBytesCount), @(wifiPacketsCount) ],
        @(NSTConnectionTypeWWAN) : @[ @(wwanBytesCount), @(wwanPacketsCount) ],
    };
}

- (void)recordBytesCount:(uint32_t)bytesCount packetsCount:(uint32_t)packetsCount forConnectionType:(NSTConnectionType)connectionType
{
    if (!bytesCount) {
        return;
    }

    NSTObject* recordObject = [NSTObject new];
    recordObject.endTimestamp = [[NSDate date] timeIntervalSince1970];
    recordObject.beginTimestamp = recordObject.endTimestamp - self.measureInterval;
    recordObject.connectionType = connectionType;
    recordObject.bytesCount = bytesCount;
    recordObject.packetsCount = packetsCount;

    NSMutableArray* kvoArray = [self mutableArrayValueForKey:NSStringFromSelector(@selector(collectedData))];

    if (self.collectedData.count >= kMaxDataCount) {
        [kvoArray removeObjectAtIndex:0];
    }

    [kvoArray addObject:recordObject];
    [self.delegate measurer:self didCollectData:recordObject];
}

- (double)maxDownloadSpeed
{
    NSString* keypath = [NSString stringWithFormat:@"@max.%@", NSStringFromSelector(@selector(bytesCount))];
    double bytesInMegabyte = 1024 * 1024;
    double maxPerMeasureInterval = [[self.collectedData valueForKeyPath:keypath] doubleValue] / bytesInMegabyte;
    return maxPerMeasureInterval / self.measureInterval;
}

- (double)averageDownloadSpeed
{
    NSString* keypath = [NSString stringWithFormat:@"@avg.%@", NSStringFromSelector(@selector(bytesCount))];
    double bytesInMegabyte = 1024 * 1024;
    double averagePerMeasureInterval = [[self.collectedData valueForKeyPath:keypath] doubleValue] / bytesInMegabyte;
    return averagePerMeasureInterval / self.measureInterval;
}

- (double)currentDownloadSpeed
{
    if (!self.collectedData.count) {
        return 0;
    }

    if ([[NSDate date] timeIntervalSinceNow] - self.collectedData.lastObject.endTimestamp > self.measureInterval) {
        return 0;
    }

    uint32_t bytesCount = self.collectedData.lastObject.bytesCount;
    double bytesPerSecondInBytes = bytesCount / self.measureInterval;
    double bytesInMegabyte = 1024 * 1024;
    return bytesPerSecondInBytes / bytesInMegabyte;
}

@end
