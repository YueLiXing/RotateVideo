//
//  RotateVideo.m
//  DownloadVideo
//
//  Created by yuelixing on 2017/5/24.
//  Copyright © 2017年 Ylx. All rights reserved.
//

#import "RotateVideo.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation RotateVideo

- (void)rotateVideoIsLeft:(BOOL)isLeft FilePath:(NSString *)filePath {
    NSString * temp = isLeft?@"left_":@"right_";
    temp = [temp stringByAppendingString:[filePath lastPathComponent]];
    NSString * targetPath = [[filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:temp];
    NSLog(@"%@", targetPath);
    [self deleteFilePath:targetPath];
    
    [self rotateVideoIsLeft:isLeft FilePath:filePath TargetPath:targetPath];
}

//关于视频旋转的一些代码
- (void)rotateVideoIsLeft:(BOOL)isLeft FilePath:(NSString *)filePath TargetPath:(NSString *)targetPath {
    [self deleteFilePath:targetPath];
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];

    CMTimeRange range = CMTimeRangeMake(kCMTimeZero, asset.duration);
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // 3 - 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError *error = nil;
    
    [videoTrack insertTimeRange:range ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeInvalid error:&error];
    // 音频
    AVMutableCompositionTrack * audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                         preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [audioTrack insertTimeRange:range ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeInvalid error:nil];
    
    CGFloat rate;
    CGFloat renderW = videoTrack.naturalSize.height;
    NSLog(@"the renderW is %f", renderW);
    NSLog(@"assetTrack.naturalSize.width is %f", videoTrack.naturalSize.width);
    NSLog(@"assetTrack.naturalSize.height is %f", videoTrack.naturalSize.height);
    rate = renderW / MIN(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
    
    CGAffineTransform preferredTransform = videoTrack.preferredTransform;
    CGAffineTransform trans = CGAffineTransformTranslate(preferredTransform, 0.0, -videoTrack.naturalSize.height);
    CGAffineTransform transNew = CGAffineTransformRotate(preferredTransform,M_PI_2*3);
    transNew = CGAffineTransformTranslate(transNew, 0, -(videoTrack.naturalSize.width - videoTrack.naturalSize.height) / 2.0);
    transNew = CGAffineTransformConcat(trans, transNew);
    transNew = CGAffineTransformScale(transNew, rate, rate);//放缩，解决前后摄像结果大小不对称
    CGAffineTransform layerTransform = CGAffineTransformMake(videoTrack.preferredTransform.a, videoTrack.preferredTransform.b, videoTrack.preferredTransform.c, videoTrack.preferredTransform.d, videoTrack.naturalSize.height * rate, videoTrack.preferredTransform.ty * rate);
    
    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//    totalDuration = CMTimeAdd(totalDuration, asset.duration);
    [layerInstruciton setTransform:transNew atTime:kCMTimeZero];
    NSMutableArray * layerInstructionArray = [NSMutableArray new];
    [layerInstructionArray addObject:layerInstruciton];
    
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = asset.duration;
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    NSURL * targetURl = [NSURL fileURLWithPath:targetPath];
    NSLog(@"targetURl %@", targetURl);
    exporter.outputURL = targetURl;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = [exporter status];
        if (status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"转码完成");
        } else if (status == AVAssetExportSessionStatusFailed) {
            NSLog(@"error : %@", [exporter error]);
        } else {
            NSLog(@"%.2f", exporter.progress);
        }
    }];
}

- (NSUInteger)degressFromVideoFileWithURL:(NSURL*)url {
    NSUInteger degress =0;
    
    AVAsset*asset = [AVAsset assetWithURL:url];
    
    NSArray*tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    if([tracks count] >0) {
        
        AVAssetTrack*videoTrack = [tracks objectAtIndex:0];
        
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if(t.a==0&& t.b==1.0&& t.c== -1.0&& t.d==0){
            
            // Portrait
            
            degress =90;
            
        } else if (t.a==0&& t.b== -1.0&& t.c==1.0&& t.d==0){
            
            // PortraitUpsideDown
            
            degress =270;
            
        } else if (t.a==1.0&& t.b==0&& t.c==0&& t.d==1.0){
            
            // LandscapeRight
            
            degress =0;
            
        } else if (t.a== -1.0&& t.b==0&& t.c==0&& t.d== -1.0){
            
            // LandscapeLeft
            
            degress =180;
            
        }
        
    }
    
    return degress;
}


// 删除沙盒里的文件
- (void)deleteFilePath:(NSString *)filePath {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL blHave = [self checkFileIsExsis:filePath];
    if (blHave) {
        NSError * error = nil;
        [fileManager removeItemAtPath:filePath error:&error];
        if (error) {
            NSLog(@"删除失败 %@", error);
        } else {
            NSLog(@"删除成功 %@", [filePath lastPathComponent]);
        }
    } else {
        NSLog(@"文件不存在");
    }
}

- (BOOL)checkFileIsExsis:(NSString *)filePath {
    if (filePath == nil || [filePath isKindOfClass:[NSString class]] == NO) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    static NSString * preFix = @"file://";
    if ([filePath hasPrefix:preFix]) {
        filePath = [filePath substringFromIndex:preFix.length];
    }
    if([fileManager fileExistsAtPath:filePath]){
        return YES;
    }else{
        return NO;
    }
}



@end
