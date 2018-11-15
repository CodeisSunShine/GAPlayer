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
    NSString *dataString = @"";
    if (exist) {
        resumeData = [NSData dataWithContentsOfFile:resumDataUrl] == nil ? nil : [NSData dataWithContentsOfFile:resumDataUrl];
        dataString = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
        NSLog(@"dataString%@",dataString);
    }
    //1.2 沙盒中有 resumeData
    if (resumeData && dataString.length > 0) {
        _downloadTask = [session downloadTaskWithResumeData:resumeData];
    } else {
        //1.3不存在 resumeData
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.itemModel.downloadUrl]];
        _downloadTask = [session downloadTaskWithRequest:request];
    }
    
}
@end
