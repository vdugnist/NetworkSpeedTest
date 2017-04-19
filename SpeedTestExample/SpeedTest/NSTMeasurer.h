//
//  NSTMeasurer.h
//  speedtest
//
//  Created by Vladislav Dugnist on 4/18/17.
//  Copyright © 2017 vdugnist. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NSTObject;
@class NSTMeasurer;

@protocol NSTMeasurerDelegate <NSObject>

- (void)measurer:(NSTMeasurer*)measurer didCollectData:(NSTObject*)data;

@end

@interface NSTMeasurer : NSObject

@property (nonatomic) NSTimeInterval measureInterval;

// all data in mb/sec
@property (nonatomic, readonly) double maxDownloadSpeed;
@property (nonatomic, readonly) double averageDownloadSpeed;
@property (nonatomic, readonly) double currentDownloadSpeed;

@property (nonatomic, weak) id<NSTMeasurerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
