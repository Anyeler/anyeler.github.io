---
layout:     post
title:      Swift的DeviceToken打印的是32Bytes
subtitle:   Swift3.1的DeviceToken打印的是32Bytes,导致推送出现问题
date:       2017-08-28
author:     Anyeler
header-img: img/post-bg-ioses.jpg
catalog: true
tags:
    - iOS
    - Swift
    - 笔记
---


【**问题描述**】使用环境 ==Swift3.1== 和 Xcode8.3.3，项目代码升级Swift3.1之后出现了DeviceToken 无法成功转 String 打印，打印出来的结果是 32Bytes。

## 解决方案

- 方案一：由于 Data没办法从64位String转成32位String Swift格式化打印，取低位。

Swift3.1代码：
```swift
//无需过滤字符 <, >, 空格
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    /*
    //写法一：
    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
    var tokenString = ""

    for i in 0..<deviceToken.length {
        tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }
    */
    
    //写法二：
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print(token)
}

```

Objective-C代码：
```
const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];

    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
```

- 方案二：由于 Data 无法转换成功，可利用 NSData 可转成 NSString

```
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {

    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                         ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                         ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                         ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

}

```



## 参考文档

[stackoverflow论坛帖子](https://stackoverflow.com/questions/9372815/how-can-i-convert-my-device-token-nsdata-into-an-nsstring)

[onevcat喵神](https://onevcat.com/2016/08/notification/)