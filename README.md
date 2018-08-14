# GAPlayer
* 播放器内核为IJKPlayer和AVPlayer 
* 目标实现: 播放+视频加解密+边下边播 
* 项目会一直维护，小伙伴们请放心使用

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

播放器的内核为IJKPlayer和AVPlayer，外层是由PlayerProtocol包裹

### 数据解析

#### 数据格式
```json
{
    "hasVideoTitle": "前言", //视频名称
    "scheme": "sd|cif|hd", //视频清晰度 sd：流畅  cif：标清 hd：高清
    "video": { //播放地址
        "cif": "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear2/prog_index.m3u8",
        "hd": "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear3/prog_index.m3u8",
        "sd": "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8"
    },
    "beginingAdUrl": "http://aliuwmp3.changba.com/userdata/video/45F6BD5E445E4C029C33DC5901307461.mp4", //片头
    "endingAdUrl": "http://aliuwmp3.changba.com/userdata/video/3B1DDE764577E0529C33DC5901307461.mp4" //片尾
}
```




下载或使用过程中遇到问题可以联系我：
邮箱：beginisgood@163.com
qq：1071854678
