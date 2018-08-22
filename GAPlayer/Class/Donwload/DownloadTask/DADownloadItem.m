//
//  DADownloadItem.m
//  GDownloadTool
//
//  Created by 宫傲 on 2018/4/11.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "DADownloadItem.h"
#import "DADownloadItemModel.h"

@implementation DADownloadItem

//生成downloadTask
- (void)createDonwloadTaskWith:(NSURLSession *)session {
    NSString *resumDataUrl = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"%@",self.itemModel.resumDataLocalName];
    //1.1 获取resumeData
    NSData *resumeData;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:resumDataUrl];
    if (exist) {
        resumeData = [NSData dataWithContentsOfFile:resumDataUrl] == nil ? nil : [NSData dataWithContentsOfFile:resumDataUrl];
        NSLog(@"dataString%@",[[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding]);
    }
    //1.2 沙盒中有 resumeData
    if (resumeData) {
        _downloadTask = [session downloadTaskWithResumeData:resumeData];
    } else {
        //1.3不存在 resumeData
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.itemModel.downloadUrl]];
        _downloadTask = [session downloadTaskWithRequest:request];
    }
}

@end
