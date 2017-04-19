//
//  ViewController.m
//  speedtest
//
//  Created by Vladislav Dugnist on 4/18/17.
//  Copyright © 2017 vdugnist. All rights reserved.
//

#import "ViewController.h"
#import "NSTMeasurer.h"

@interface ViewController ()

@property (nonatomic) NSTMeasurer* measurer;
@property (weak, nonatomic) IBOutlet UILabel* maxSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel* averageSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel* currentSpeedLabel;

@property (weak, nonatomic) IBOutlet UITextField* textField;

@end

NSString* maxSpeedKeyPath()
{
    return NSStringFromSelector(@selector(maxDownloadSpeed));
}

NSString* avgSpeedKeyPath()
{
    return NSStringFromSelector(@selector(averageDownloadSpeed));
}

NSString* currentSpeedKeyPath()
{
    return NSStringFromSelector(@selector(currentDownloadSpeed));
}

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.measurer = [NSTMeasurer new];

        [self.measurer addObserver:self forKeyPath:maxSpeedKeyPath() options:NSKeyValueObservingOptionNew context:NULL];
        [self.measurer addObserver:self forKeyPath:avgSpeedKeyPath() options:NSKeyValueObservingOptionNew context:NULL];
        [self.measurer addObserver:self forKeyPath:currentSpeedKeyPath() options:NSKeyValueObservingOptionNew context:NULL];
    }

    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:maxSpeedKeyPath()];
    [self removeObserver:self forKeyPath:avgSpeedKeyPath()];
    [self removeObserver:self forKeyPath:currentSpeedKeyPath()];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id>*)change
                       context:(void*)context
{
    if ([keyPath isEqualToString:maxSpeedKeyPath()]) {
        double speed = [change[NSKeyValueChangeNewKey] doubleValue];
        self.maxSpeedLabel.text = [NSString stringWithFormat:@"%.3f", speed];
        return;
    }

    if ([keyPath isEqualToString:avgSpeedKeyPath()]) {
        double speed = [change[NSKeyValueChangeNewKey] doubleValue];
        self.averageSpeedLabel.text = [NSString stringWithFormat:@"%.3f", speed];
        return;
    }

    if ([keyPath isEqualToString:currentSpeedKeyPath()]) {
        double speed = [change[NSKeyValueChangeNewKey] doubleValue];
        self.currentSpeedLabel.text = [NSString stringWithFormat:@"%.3f", speed];
        return;
    }

    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (IBAction)downloadButtonPressed:(id)sender
{
    if (!self.textField.text.length) {
        return;
    }

    NSURL* url = [NSURL URLWithString:self.textField.text];
    if (!url) {
        return;
    }

    [[[NSURLSession sharedSession] downloadTaskWithURL:url
                                     completionHandler:^(NSURL* _Nullable location, NSURLResponse* _Nullable response, NSError* _Nullable error){
                                     }]
        resume];
}

@end
