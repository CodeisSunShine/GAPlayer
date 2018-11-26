//
//  DADownloadUrlResolver.m
//  GDownloadTool
//
//  Created by 宫傲 on 2018/4/13.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "DADownloadUrlResolver.h"
#import "M3U8Parser+String.h"
#import "DADownloadItem.h"
#import "DownloadError.h"
#import "TFHpple.h"

/**
 * m3u8 后缀名
 */
#define M3U8SuffixName      @"m3u8"

/**
 * m3u8 后缀名
 */
#define htmlSuffixName      @"html"

#define SRC @"src"
#define HREF @"href"

@implementation DADownloadUrlResolver

+ (void)analysisDownloadUrls:(NSArray *)downloadUrls
                    localUrl:(NSString *)localFileUrl
                downloadName:(NSString *)downloadName
                 finishBlock:(void(^)(BOOL success, id object))finishBlock {
    __block NSMutableArray *totalDownloadUrls = [[NSMutableArray alloc] init];
    __block NSMutableArray *totalDownloadNames = [[NSMutableArray alloc] init];
    __block NSInteger successCount = 0;
    __block NSMutableArray *errorUrls = [[NSMutableArray alloc] init];
    
    // 同一个下载任务中 多个解析任务并行
    dispatch_queue_t dispatchQueue = dispatch_queue_create("Resolver.queue.", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    [downloadUrls enumerateObjectsUsingBlock:^(NSString *downloadUrl, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_async(dispatchGroup, dispatchQueue, ^(){
            // 此时使用信号量是防止处理时下载地址的时候采用异步的方式
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [self analysisURL:downloadUrl localUrl:localFileUrl downloadName:downloadName finishBlock:^(BOOL success, NSArray *downloadUrls, NSArray *names) {
                if (success) {
                    // 1.1.1 successCount++
                    successCount ++;
                    // 1.1.2 将处理好的下载地址加入下载队列中
                    [totalDownloadUrls addObjectsFromArray:downloadUrls];
                    [totalDownloadNames addObjectsFromArray:names];
                } else {
                    [errorUrls addObject:downloadUrl];
                    NSLog(@"解析 ------ %@ ------ 失败",downloadUrl);
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
        });
    }];
    // 所有解析任务完成后进行判断
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        if ((successCount == downloadUrls.count) &&  errorUrls.count == 0) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            dict[@"totalDownloadUrls"] = [totalDownloadUrls copy];
            dict[@"totalDownloadNames"] = [totalDownloadNames copy];
            finishBlock(YES,dict);
        } else {
            NSString *downloadUrl;
            if (errorUrls.count > 0) {
                downloadUrl = [errorUrls componentsJoinedByString:@"-"];
            } else {
                downloadUrl = [downloadUrls componentsJoinedByString:@"-"];
            }
            DownloadError *error = [[DownloadError alloc] initWithinishCode:kDADownloadFinishCodeParseFailure customeReason:downloadUrl];
            finishBlock(NO,error);
            NSLog(@"有下载地址解析失败");
        }
        NSLog(@"downloadUrlArray ----- %ld",totalDownloadUrls.count);
    });
}


//统一 解析下载地址的形式
+ (void)analysisURL:(NSString *)downloadUrl
           localUrl:(NSString *)localFileUrl
       downloadName:(NSString *)downloadName
        finishBlock:(void(^)(BOOL success, NSArray *downloadUrls, NSArray *names))finishBlock {
    // 1.判断下载类型
    NSURLComponents *urlParts = [NSURLComponents componentsWithURL:[NSURL URLWithString:downloadUrl] resolvingAgainstBaseURL:NO];
    NSString *extension = urlParts.URL.pathExtension;
    if ([extension isEqualToString:M3U8SuffixName]) {
        // 1.1 m3u8
        [self analysisM3U8File:downloadUrl downloadName:downloadName localUrl:localFileUrl andFinish:finishBlock];
    } else if ([extension isEqualToString:htmlSuffixName]){
        // 1.2 html
        [self analysisHTMLFile:downloadUrl localUrl:localFileUrl downloadName:downloadName finishBlock:finishBlock];
    } else {
        // 1.3 其他类型 暂时不做处理直接返回
        finishBlock (YES,@[downloadUrl],@[downloadName]);
    }
}

//解析M3U8
+ (void)analysisM3U8File:(NSString *)m3u8Url
            downloadName:(NSString *)downloadName
                localUrl:(NSString *)localFileUrl
               andFinish:(void(^)(BOOL success, NSArray *downloadUrls, NSArray *names))finishBlock {
    NSMutableURLRequest *m3u8Request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:m3u8Url]
                                                                   cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                               timeoutInterval:10];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:m3u8Request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSString *m3u8Str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSRange range = [m3u8Url rangeOfString:@"/" options:NSBackwardsSearch];
            NSString *rootUrl = [m3u8Url substringToIndex:range.location];
            M3U8Parser *m3u8Parser = [[M3U8Parser alloc]initWithM3U8String:m3u8Str rootUrl:rootUrl];
            
            NSError *error = [self writeFileToLocalFileUrl:localFileUrl downloadName:downloadName contentStr:m3u8Parser.lastM3U8String];
            if (error) {
                NSLog(@"m3u8文件创建失败");
                finishBlock(NO,nil,nil);
            } else {
                finishBlock(YES,m3u8Parser.tsUrlMutableArray,m3u8Parser.tsNameMutableArray);
                NSLog(@"成功");
            }
        } else {
            finishBlock(NO,nil,nil);
            NSLog(@"失败");
        }
    }];
    [task resume];
    
}

//解析HTML文件
+ (void)analysisHTMLFile:(NSString *)htmlURL
                localUrl:(NSString *)localFileUrl
            downloadName:(NSString *)downloadName
             finishBlock:(void(^)(BOOL success, NSArray *downloadUrls, NSArray *names))finishBlock{
    if (htmlURL.length) {
        NSString *htmlStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:htmlURL] encoding:NSUTF8StringEncoding error:nil];
        NSData* data=[htmlStr dataUsingEncoding: NSUTF8StringEncoding];
        NSRange r=[htmlURL rangeOfString:@"/" options:NSBackwardsSearch];
        NSString *root=[htmlURL substringToIndex:r.location];
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        
        NSMutableArray *nameList = [[NSMutableArray alloc] init];
        NSMutableArray *arrayList = [[NSMutableArray alloc] init];
        
        //解析JS
        NSArray *JS = [xpathParser searchWithXPathQuery:@"//script"];
        htmlStr = [self parseHtmlArray:JS returnStr:htmlStr rootPath:root attrName:SRC andNameList:nameList andArrayList:arrayList];
        
        //解析CSS
        NSArray *css=[xpathParser searchWithXPathQuery:@"//link"];
        htmlStr=[self parseHtmlArray:css returnStr:htmlStr rootPath:root attrName:HREF andNameList:nameList andArrayList:arrayList];
        
        //解析img
        NSArray *img = [xpathParser searchWithXPathQuery:@"//img"];
        htmlStr=[self parseHtmlArray:img returnStr:htmlStr rootPath:root attrName:SRC andNameList:nameList andArrayList:arrayList];
    
       NSError *error = [self writeFileToLocalFileUrl:localFileUrl downloadName:downloadName contentStr:htmlStr];
        
        if (!error) {
            if (nameList.count == arrayList.count) {
                finishBlock(YES,arrayList,nameList);
            } else {
                NSLog(@"讲义解析失败");
                finishBlock(NO,nil,nil);
            }
        } else {
            NSLog(@"讲义文件创建失败");
            finishBlock(NO,nil,nil);
        }
    } else {
        finishBlock(NO,nil,nil);
    }
}

/**
 解析htm标签属性，同时返回修改后的html文本
 @param arry 某个标签的数组
 @param htmlStr html网页文本
 @param rootPath 文件绝对路径
 @param attrName 属性字符穿，如“src”、“href”
 @returns 返回修改后的html网页文本
 */
+ (NSString *)parseHtmlArray:(NSArray *)arry
                   returnStr:(NSString *)htmlStr
                    rootPath:(NSString *)rootPath
                    attrName:(NSString *)attrName
                 andNameList:(NSMutableArray *)nameList
                andArrayList:(NSMutableArray *)arrayList{
    for(TFHppleElement *s in arry){
        NSString *attr = [[s attributes] objectForKey:attrName];
        //html标签是否有该属性
        if (!attr) {
            continue;
        }
        //判断是相对路径/绝对路径
        if (!([attr hasPrefix:@"http://"] || [attr hasPrefix:@"https://"])) {
            attr = [NSString stringWithFormat:@"%@/%@",rootPath,attr];
        }
        
        NSArray *array = [attr componentsSeparatedByString:@"/"];
        if((![arrayList containsObject:attr]) && (![nameList containsObject:array.lastObject])){
            [arrayList addObject:attr];
            [nameList addObject:array.lastObject];
        }
        
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:[[s attributes] objectForKey:attrName] withString:[self getFileName:attr]];
    }
    return htmlStr;
}

/**
 返回url（绝对路径）中文件名称
 @param url 文件路径
 @returns 文件名(test01.ts)
 */
+ (NSString *)getFileName:(NSString*)url {
    NSRange range = [url rangeOfString:@"/" options:NSBackwardsSearch];
    return [url substringFromIndex:range.location + 1];
}

+ (NSError *)writeFileToLocalFileUrl:(NSString *)localFileUrl
                        downloadName:(NSString *)downloadName
                          contentStr:(NSString *)contentStr {
    NSString *anAbsolutePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@",localFileUrl];
    [self isExistPath:anAbsolutePath];
    //写文件到本地(leture.htm)
    NSString *path = [anAbsolutePath stringByAppendingPathComponent:downloadName];
    //    [htmlStr writeToFile: path atomically: YES];
    NSError *error;
    [contentStr writeToFile:path atomically:YES encoding:(NSUTF8StringEncoding) error:&error];
    return error;
}

/**
 某文件夹是否存在，没有则创建
 @param path文件夹路径
 */
#pragma mark - 创建下载文件
+ (void)isExistPath:(NSString *)path {
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end
