//
//  DADonwloadHandle.m
//  DownloadFramework
//
//  Created by 宫傲 on 2018/6/11.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "DADonwloadHandle.h"
#import <CommonCrypto/CommonDigest.h>
#import "DADownloadUrlResolver.h"
#import "DADownloadItemModel.h"
#import "DADownloadSession.h"
#import "DADownloadModel.h"
#import "DownloadError.h"

@implementation DADonwloadHandle

#pragma mark - public
- (void)downloadWithDownloadUrls:(NSArray *)downloadUrls
                     andLocalUrl:(NSString *)localFileUrl
                      downloadId:(NSString *)downloadId
                    downloadName:(NSString *)downloadName
             andAnalysisURLBlock:(void(^)(BOOL success, id <DonwloadServiceProtocol> downloader, DownloadError *error))analysisURLBlock {
    
    //1. 判断本地地址是否错误
    NSError *fileError = [self makeProgressLocalUrl:localFileUrl];
    if (fileError) {
        analysisURLBlock(NO,nil,[[DownloadError alloc] initWithinishCode:kDADownloadFinishCodeFailToRoot error:fileError]);
        return;
    }
    __weak typeof(self)weakSelf = self;
    //2.解析 下载地址
    [DADownloadUrlResolver analysisDownloadUrls:downloadUrls localUrl:localFileUrl downloadName:downloadName finishBlock:^(BOOL success, id object) {
        if (success) {
            NSArray *names = object[@"totalDownloadNames"];
            NSArray *downloadUrls = object[@"totalDownloadUrls"];
            
            //2.1 组织downloadModel
            DADownloadModel *downloadModel = [weakSelf makeProgressWithDownloadUrls:downloadUrls andNames:names andLocalUrl:localFileUrl downloadId:downloadId];
            
            //2.2 生成相应的downloader
            id <DonwloadServiceProtocol> downloader = [self downloadWithDownloadModel:downloadModel];
            downloader.downloadModel.downloadTitle = downloadName;
            analysisURLBlock(YES,downloader,nil);
            
        } else {
            analysisURLBlock(NO,nil,object);
        }
    }];
    
}

- (id <DonwloadServiceProtocol>)downloadWithDownloadModel:(DADownloadModel *)downloadModel {
    id <DonwloadServiceProtocol> downloader = [[DADownloadSession alloc] initWithDownloadModel:downloadModel];
    return downloader;
}

#pragma mark - private
- (DADownloadModel *)makeProgressWithDownloadUrls:(NSArray *)downloadUrls andNames:(NSArray *)names andLocalUrl:(NSString *)localFileUrl downloadId:(NSString *)downloadId {
    DADownloadModel *downloadModel = [[DADownloadModel alloc] init];
    downloadModel.downloadId = downloadId;
    //1 组织储存路径
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < downloadUrls.count; i++) {
        DADownloadItemModel *itemModel = [[DADownloadItemModel alloc] init];
        itemModel.finishLocalName = [NSString stringWithFormat:@"/%@/%@",localFileUrl,names[i]];
        itemModel.resumDataLocalName = [self makeProgressUrlWith:@"resumeData" andLocalName:itemModel.finishLocalName];
        itemModel.downloadUrl = downloadUrls[i];
        itemModel.totalBytesExpectedToWrite = @"0";
        itemModel.totalBytesWritten = @"0";
        itemModel.isFinish = @"0";
        [itemArray addObject:itemModel];
    }
    downloadModel.downloadItemArray = [itemArray copy];
    
    //2 初始化下载状态
    downloadModel.downloadState = kDADownloadStateReady;
    downloadModel.pathName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@",localFileUrl];
    
    return downloadModel;
}

- (NSError *)makeProgressLocalUrl:(NSString *)localFileUrl {
    NSString *localUrl = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@",localFileUrl];
    //1.1判断外界传来的存储地址是否有效
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:localUrl isDirectory:&isDir];
    if (existed) {
        return nil;
    } else {
        //不存在则创建
        NSError *ceateError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:localUrl withIntermediateDirectories:YES attributes:nil error:&ceateError];
        if (ceateError) {
            NSLog(@"ceateError -------- %@",ceateError);
            return ceateError;
        } else {
            return nil;
        }
    }
}

//md5
- (NSString *)md5HexDigest:(NSString*)input
{
    const char* cStr = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (uint32_t)strlen(cStr), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (NSInteger i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    return ret;
    
}

//创建存储路径
- (NSString *)makeProgressUrlWith:(NSString *)typeString andLocalName:(NSString *)localName{
    NSArray *stringArray = [localName componentsSeparatedByString:@"."];
    if (stringArray.count > 1) {
        NSMutableArray *stringMutableArray = [NSMutableArray arrayWithArray:stringArray];
        [stringMutableArray removeLastObject];
        [stringMutableArray addObject:typeString];
        return [stringMutableArray componentsJoinedByString:@"."];
    } else {
        return nil;
    }
}

@end
