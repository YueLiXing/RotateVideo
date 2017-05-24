//
//  RotateVideo.h
//  DownloadVideo
//
//  Created by yuelixing on 2017/5/24.
//  Copyright © 2017年 Ylx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RotateVideo : NSObject

- (void)rotateVideoIsLeft:(BOOL)isLeft FilePath:(NSString *)filePath;

- (void)rotateVideoIsLeft:(BOOL)isLeft FilePath:(NSString *)filePath TargetPath:(NSString *)targetPath;

@end
