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

@property (nonatomic, retain) RotateVideo * tool;

@property (nonatomic, copy) NSString * leftTargetPath;
@property (nonatomic, copy) NSString * rightTargetPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tool = [RotateVideo new];
    
    NSString * temp = [NSSearchPathForDirectoriesInDomains(NSMoviesDirectory, NSUserDomainMask, YES) firstObject];
    temp = [temp stringByAppendingPathComponent:@"DownloadVideo"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:temp] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:temp withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"视频输出路径 %@", temp);
    
    self.filePath = [[NSBundle mainBundle] pathForResource:@"950e459557f3170b31e40c41185d9ae6" ofType:@"mp4"];
    

    self.leftTargetPath = [temp stringByAppendingPathComponent:@"left.mp4"];
    self.rightTargetPath = [temp stringByAppendingPathComponent:@"right.mp4"];
    
}
- (IBAction)rotateLeft:(id)sender {
    [self.tool rotateVideoIsLeft:YES FilePath:self.filePath TargetPath:self.leftTargetPath];
}
- (IBAction)rotateRight:(id)sender {
    [self.tool rotateVideoIsLeft:NO FilePath:self.filePath TargetPath:self.rightTargetPath];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
