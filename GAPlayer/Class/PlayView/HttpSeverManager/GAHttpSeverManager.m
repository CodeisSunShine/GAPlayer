//
//  GAHttpSeverManager.m
//  GAPlayer
//
//  Created by 宫傲 on 2018/8/22.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#import "GAHttpSeverManager.h"

#import "HTTPServer.h"

#define DefaultTryCount 3

// 会根据项目情况进行修改
#define kDownloadRootPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

@interface GAHttpSeverManager ()

@property (nonatomic, strong) HTTPServer *httpServer;

/**
 * 尝试开启的次数
 */
@property (nonatomic, assign) NSInteger tryTestNum;

@end

@implementation GAHttpSeverManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GAHttpSeverManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GAHttpSeverManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public functions

- (void)startServer {
    NSError *error;
    if([self.httpServer start:&error]) {
        //#warning 项目不同替换nslog
        self.tryTestNum = 0;
        NSLog(@"Started HTTP Server on port %hu", [self.httpServer listeningPort]);
    }
    else {
        self.tryTestNum ++;
        if (self.tryTestNum < DefaultTryCount) {
            [self stopServer];
            [self startServer];
        }
        else
        {
            self.tryTestNum = 0;
        }
        NSLog(@"Error starting HTTP Server: %@", error);
    }
}

- (void)stopServer {
    [self.httpServer stop];
    self.httpServer = nil;
}

#pragma mark – getters and setters
/**
 * 初始化httpserver
 */
- (HTTPServer *)httpServer {
    
    if (_httpServer == nil) {
        self.httpServer = [[HTTPServer alloc] init];
        [_httpServer setName:@"GAPlayer"];
        [_httpServer setPort:1025]; //注意此时的端口号要与 kLocalPlayURL 保持一致
        //设置成m3u8的下载地址
        NSString *rootPath = kDownloadRootPath;
        [_httpServer setDocumentRoot:rootPath];
    }
    return _httpServer;
}

@end
