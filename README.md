# GAPlayer
* 播放器内核为IJKPlayer和AVPlayer 
* 目标实现: 播放+视频加解密+边下边播 
* 项目会一直维护，小伙伴们请放心使用

## 效果：
<div float="left">
  <img src="https://github.com/CodeisSunShine/Image/blob/master/1.2018-11-26%2020_09_27.gif" width = "300">
</div>
<div float="right">
  <img src="https://github.com/CodeisSunShine/Image/blob/master/2.2018-11-26 20_04_41.gif" width = "300">
</div>

## 下载教程：

因为 github允许上传的文件上限为100MB IJKMediaFramework 较大所以造成了下载不便请谅解（好事多磨！ 👍）

### Git LFS

1. 安装 Homebrew （如果已安装可以跳过）
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
2. brew install git-lfs
3. git lfs install
4. git lfs clone https://github.com/CodeisSunShine/GAPlayer.git

文件较大，可能下载时间会稍长

### GitHub + 百度云盘

1. 直接点击clone
2. 下载 IJKMediaFramework 下载地址 链接: https://pan.baidu.com/s/1cM9LuHWWdC5nZZCTy6ywyQ 密码: rqb2
3. 用云盘下载下来的 IJKMediaFramework 替换 clone 工程中的 IJKMediaFramework.framewrok


## 使用教程

### 项目架构

<div align="center">
  <img src="https://github.com/CodeisSunShine/Image/raw/master/GAPlayer.png">
</div>

* GAPlayerView：最外层播放视图，里面包含播放器的业务逻辑和视图逻辑。
* PlayerProtocol：包裹播放器内核的协议，GAPlayerView不直接与播放器交互，而是通过PlayerProtocol使用播放器。
* AVPlayer: AVPlayer播放器内核，封装了用到AVPlayer的各种方法和属性
* IJKPlayer: IJKPlayer播放器内核，封装了用到IJKPlayer的各种方法和属性

播放器的内核为IJKPlayer和AVPlayer，外层是由PlayerProtocol包裹

### 数据解释

根据业务的不同，播放器需要的数据结构也不同，所以此时使用json格式的数据与播放器进行交互。

```json
{
    "hasVideoTitle": "前言", //视频名称
    "scheme": "sd|cif|hd", //视频清晰度 sd：流畅  cif：标清 hd：高清
    "video": { //播放地址
        "cif": "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8",
        "hd": "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear3/prog_index.m3u8",
        "sd": "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8"
    },
    "isOnline": "1", // 是否是在线播放：0 本地 1 离线
    "beginingAdUrl": "http://aliuwmp3.changba.com/userdata/video/45F6BD5E445E4C029C33DC5901307461.mp4", //片头
    "endingAdUrl": "http://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4" //片尾
}
```

### 使用Tip
#### 1.播放器使用
##### 1.1.懒加载播放器 GAPlayerView
```
- (GAPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[GAPlayerView alloc] init];
    }
    return _playerView;
}
```
##### 1.2 设置播放器frame
```
[self.view addSubview:self.playerView];
self.playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 16.0 * 9);
```
##### 1.3 增加横竖屏回调
```
[self.playerView registerLandscapeCallBack:^(UIInterfaceOrientation deviceOrientation, UIInterfaceOrientation statusBarOrientation) {
   if (deviceOrientation == UIInterfaceOrientationPortrait) {
       weakself.playerView.isFullScreen = NO;
       weakself.playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 16*9);
   } else {
       weakself.playerView.isFullScreen = YES;
       weakself.playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH / 16.0*9, SCREEN_WIDTH);
   }
}];
```
##### 1.4 组织播放器需要的数据源
根据业务的不同，播放器需要的数据结构也不同，所以此时使用json格式的数据与播放器进行交互。scheme和video中的数据要对应起来。

```json
{
    "hasVideoTitle": "前言", //视频名称
    "scheme": "sd|cif|hd", //视频清晰度 sd：流畅  cif：标清 hd：高清
    "video": { //播放地址
        "cif": "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8",
        "hd": "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear3/prog_index.m3u8",
        "sd": "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8"
    },
    "isOnline": "1", // 是否是在线播放：0 本地 1 离线
    "beginingAdUrl": "http://aliuwmp3.changba.com/userdata/video/45F6BD5E445E4C029C33DC5901307461.mp4", //片头
    "endingAdUrl": "http://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4" //片尾
}
```
##### 1.5 切换内核
在 GAPlayerView 类中的 initializingPlayer 方法里 可通过下面的方式切换播放器内核（🙂）
```
 self.player = [[GAIJKPlayer alloc] initWith:self.playerView];
// self.player = [[GAAVPlayer alloc] initWith:self.playerView];
```

#### 2.播放器代码解释
##### 2.1 IJKPlayer和AVPlayer的不同
1. IJKPlayer的播放状态是通过通知进行监听，而AVPlayer是通过KVO进行监听。
2. IJKPlayer的时间单位为NSTimeInterval，而AVPlayer的时间单位为CMTime。
##### 2.2 横竖屏
项目中的UIView+SomehowTheScreen，可以为所有的UIView添加横竖屏的功能。如果你的其他项目需要给view添加横竖屏的功能，请放心引用它吧。
其对外有两个方法：
```
/**
 注册横竖屏的回调
 */
- (void)registerLandscapeCallBack:(void(^)(UIInterfaceOrientation deviceOrientation,UIInterfaceOrientation statusBarOrientation))directionChangeBlcok;

/**
 将屏幕转向指定方向
 */
- (void)toOrientation:(UIInterfaceOrientation)deviceOrientation;
```
>其中有一个小问题，需要再用到横竖屏的UIView里将通知删除
##### 2.3 手势
我把手势的方法封装在GAPlayerView+GestureAction里了
```
/**
 注册手势
 */
- (void)registerForGestureEvents:(void(^)(GsetureType gsetureType,CGFloat moveValue))gsetureBlock;

/**
 开启/恢复 手势
 */
- (void)startForGestureEvents;

/**
 取消手势
 */
- (void)cancelForGestureEvents;
```
手势类型有：
```
/**
 * 手势类型
 */
typedef NS_ENUM(NSUInteger, GsetureType) {
    /** 初始无手势 */
    kGsetureTypeNone = 0,
    /** 左侧竖直滑动 */
    kGsetureTypeLeftVertical = 1,
    /** 右侧竖直滑动 */
    kGsetureTypeRightVertical = 2,
    /** 水平滑动 */
    kGsetureTypeHorizontal = 3,
    /** 单击 */
    kGsetureTypeSingleTap = 4,
    /** 双击 */
    kGsetureTypeDoubleTap = 5,
    /** 手势取消 */
    kGsetureTypeCancel = 6,
    /** 手势结束 */
    kGsetureTypeEnd = 7
};
```
##### 2.4 播放本地视频
如果是MP4和MP3的话，将资源下载到本地就可以直接进行播放了，但是M3U8格式的资源比较特殊。
需要将下载好的M3U8的资源本地模拟为http请求才能进行本地视频的播放。在项目中，我用的是[CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer)，并将其封装在GAHttpSeverManager中
```
/**
 * 初始化
 */
+ (instancetype)sharedInstance;

/**
 * 启动httpserver
 */
- (void)startServer;

/**
 * 关闭httpserver
 */
- (void)stopServer;
```

#### 3.下载功能使用
##### 3.1 初始化缓存器
```
- (GACacheManager *)cacheManager {
    if (!_cacheManager) {
        _cacheManager = [[GACacheManager alloc] init];
    }
    return _cacheManager;
}
```
##### 3.2 绑定回调
```
[self.cacheManager addProgressBlock:^(NSString *downloadId, NSString *progress, int64_t speed) {
    NSLog(@"下载进度回调");
} downloadStateBlock:^(NSString *downloadId, NSInteger downloadState) {
    NSLog(@"下载状态回调");
} finishBlock:^(NSString *downloadId, BOOL success, NSError *error) {
    NSLog(@"下载完成/失败");
} idClass:@"id"];
```
##### 3.3 开启下载
```
__weak __typeof(self) weakself= self;
NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
dict[@"videoId"] = @"";//下载id
dict[@"videoName"] = @"";//下载名称
dict[@"videoUrl"] = @"";//下载地址
[self.cacheManager addDownloadWith:[dict copy] callBlock:^(BOOL success, id object) {
    if (success) {
        NSLog(@"成功进入下载逻辑");
    } else {
        NSLog(@"下载失败  %@",object);
    }
}];
```
##### 3.4 下载操作
```
[self.cacheManager downloadIsControlledAccordingToVideoId:@"" callBlock:^(BOOL success, id object) {
   
}];
```
##### 3.5 下载任务并发数控制
改变GACacheManager 中 maxDonwloadingCount的值
```
- (NSInteger)maxDonwloadingCount {
    return 2;
}
```
##### 3.6 解除回调绑定
改变GACacheManager 中 maxDonwloadingCount的值
```
[self.cacheManager removeDonwloadBlcokWithIdClass:@""];
```

### 问题反馈 

下载或使用过程中遇到问题可以联系我：
* 邮箱：beginisgood@163.com
* qq：1071854678
