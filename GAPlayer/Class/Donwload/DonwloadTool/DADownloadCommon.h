//
//  DADownloadCommon.h
//  GDownloadTool
//
//  Created by 宫傲 on 2018/4/11.
//  Copyright © 2018年 宫傲. All rights reserved.
//

#ifndef DADownloadCommon_h
#define DADownloadCommon_h

/**
 * 当前文件下载的状态
 */
typedef NS_ENUM(NSUInteger, DADownloadState) {
    /** 这个download被实例化，但是并没有开始下载 */
    kDADownloadStateReady = 0,
    /** 等待下载 */
    kDADownloadStateWait,
    /** 下载已经开始，并接收文件 */
    kDADownloadStateDownloading,
    /** 下载成功完成 */
    kDADownloadStateCompleted,
    /** 下载被人为cancelled */
    kDADownloadStateCancelled,
    /** 下载失败 */
    kDADownloadStateFailed
};

/**
 * 下载状态码
 */
typedef NS_ENUM(NSUInteger, DADownloadFinishCode) {
    /** 下载成功 */
    kDADownloadFinishCodeSuccess = 10,
    /** 无效网络 */
    kDADownloadFinishCodeNotReachable = 20,
    /** Item丢失 */
    kDADownloadFinishCodeItemLose = 30,
    /** 切片转移失败 */
    kDADownloadFinishCodeMoveFail = 40,
    /** 下载任务不完整 */
    kDADownloadFinishCodeIncomplete = 50,
    /** 下载地址解析失败 */
    kDADownloadFinishCodeParseFailure = 60,
    /** 创建下载根目录失败 */
    kDADownloadFinishCodeFailToRoot = 70
};

#endif /* DADownloadCommon_h */
