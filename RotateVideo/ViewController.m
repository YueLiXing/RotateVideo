//
//  ViewController.m
//  RotateVideo
//
//  Created by yuelixing on 2017/5/24.
//  Copyright © 2017年 Ylx. All rights reserved.
//

#import "ViewController.h"
#import "RotateVideo.h"

@interface ViewController ()

@property (nonatomic, copy) NSString * filePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * temp = [NSSearchPathForDirectoriesInDomains(NSMoviesDirectory, NSUserDomainMask, YES) firstObject];
    temp = [temp stringByAppendingPathComponent:@"DownloadVideo"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:temp] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:temp withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"视频输出路径 %@", temp);
    
    self.filePath = [[NSBundle mainBundle] pathForResource:@"950e459557f3170b31e40c41185d9ae6" ofType:@"mp4"];
}
- (IBAction)rotateLeft:(id)sender {
    [[RotateVideo new] rotateVideoIsLeft:YES FilePath:self.filePath];
}
- (IBAction)rotateRight:(id)sender {
    [[RotateVideo new] rotateVideoIsLeft:NO FilePath:self.filePath];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
