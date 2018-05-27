---
layout:     post
title:      浅谈IOS TouchID以及APP的数字锁屏
subtitle:   iOS开发中遇到的锁屏功能常常会使用到指纹验证
date:       2017-01-15
author:     Anyeler
header-img: img/post-bg-ios9-web.jpg
catalog: true
tags:
    - iOS
    - 开发技巧
---

【**摘要**】最近公司有个需求就是对APP进行加入屏幕解锁以及指纹解锁的功能。开始以为十分简单，其实本质上的难点不是在实现指纹验证的方面，而是APP生命周期的控制。

***

## APP需求分析
- 屏幕数字密码为四位数字组成，界面类似于IPhone的屏幕锁
- 在数字密码存在的基础上添加指纹解锁功能
- 启动APP支持指纹的设备可用指纹进行登录
- 程序从后台一段时间后回来需要解锁，没有过规定的时间不用解锁
- 设备不支持指纹的情况，启动程序需要进行数字解锁
- 输入一定次数密码错误后要重新登录

***

## 技术要点
- **TouchID技术**：需要用到苹果封装好的框架
- **线程管理**：不管是UI更新还是TouchID的处理，都必须要注意的一点
- **APP生命周期**： 由于屏幕解锁涉及到后台以及程序的启动，那么就必须清楚的知道APP启动的生命周期函数，并利用这些函数进行适当的编程
- **UIWindow的管理**：通过掌握UIWindow的管理，才能进行锁屏界面和APP主界面进行任意切换。

***

## TouchID使用详解
【**简介**】TouchID也就是所谓的指纹验证，实际上是通过识别和采集生物特征码进行验证是否为本人，和人脸识别、虹膜识别等生物识别架构有点相似。由于 *IOS 8.0* 之后，才开放TouchID的指纹验证的API，所以必须判断IOS版本号。

- **第一步**：导入LocalAuthentication.framework框架
![LocalAuthentication.framework](http://upload-images.jianshu.io/upload_images/2613685-3ab3156e334f06bf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
在使用TouchID的控制器下导入头文件：
Swift3.0代码：
```swift
import LocalAuthentication
```
Objective-C代码：
```objective-C
#import <LocalAuthentication/LocalAuthentication.h>
```

- **第二步**：判断是否为 *IOS8.0* 系统
Swift3.0代码：
```swift
guard Double(UIDevice.current.systemVersion)! >= 8.0 else { return }
```
Objective-C代码：
```objective-C
//iOS8.0后才支持指纹识别接口
if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
       return;
}
```

- **第三步**：判断 *TouchID* 是否可用并验证
Swift3.0代码：
```swift
    func touchIDHandler() {
        let context = LAContext()
        //验证失败后，按钮的文字，默认是输入密码
        context.localizedFallbackTitle = "输入密码按钮文字"
        var error: NSError? = nil
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "指纹解锁", reply: { (success, error) in
                if success {
                } else {
                    //错误处理
                    print(error?.localizedDescription)
                    switch LAError(_nsError: error as! NSError).code {
                    case .systemCancel:
                        //系统取消授权，如其他APP切入
                        break
                    case .userCancel:
                        //用户取消验证Touch ID
                        break
                    case .authenticationFailed:
                        //授权失败
                        break
                    case .passcodeNotSet:
                        //系统未设置密码
                        break
                    case .touchIDNotAvailable:
                        //设备Touch ID不可用，例如未打开
                        break
                    case .touchIDNotEnrolled:
                        //
                        break
                    case .userFallback:
                        OperationQueue.main.addOperation({ 
                            //用户选择输入密码，切换主线程处理
                        })
                    default:
                        OperationQueue.main.addOperation({ 
                            //其他情况，切换主线程处理
                        })
                    }
                }
            })
        }
    }
```
Objective-C代码：
```objective-C
 - (void)touchIDHandler {
    LAContext *context = [[LAContext alloc] init];
    //验证失败后，按钮的文字，默认是输入密码
    context.localizedFallbackTitle = @"输入密码按钮文字";
    
    NSError *error;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) { //判断是否支持指纹
        //指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"指纹解锁" reply:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"%@", [NSThread currentThread]); //当前处于子线程中
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", [NSThread currentThread]);
                    //在主线程中更新UI
                });
            } else {
                //错误处理
                NSLog(@"%@", error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        //系统取消授权，如其他APP切入
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        //用户取消验证Touch ID
                        break;
                    }
                    case LAErrorAuthenticationFailed:
                    {
                        //授权失败
                        break;
                    }
                    case LAErrorPasscodeNotSet:
                    {
                        //系统未设置密码
                        break;
                    }
                    case LAErrorTouchIDNotAvailable:
                    {
                        //设备Touch ID不可用，例如未打开
                        break;
                    }
                    case LAErrorTouchIDNotEnrolled:
                    {
                        //设备Touch ID不可用，用户未录入
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //用户选择输入密码，切换主线程处理
                            
                        }];
                        break;
                    }
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //其他情况，切换主线程处理
                        }];
                        break;
                    }
                }
            }
        }];
    }
}
```

***

## APP生命周期详解
【**简介**】APP的生命周期是基于 runtime 的机制，本文不对 runtime 以及 AppDelegate 进行详细的解读以及介绍。下面将对项目自动生成的主要方法进行简单介绍。
Swift3.0 代码如下：
```swift
    /*
     *该方法初始化程序后， 系统会调用
     */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        /* 
         * 在这个方法里可以做系统主要窗口的和根控制器的初始化；
         * 可以对一些第三方库的初始化操作；
         * 对一些app而言，获取用户信息的操作不必放在这里（具体情况而言）；
         */
        return true
    }

    /*
     *该方法初始化程序后， 每次进入程序会调用
     */
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    /*
     * 该方法已经进入后台会调用
     */
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        /*
         * 这里记录进入后台的时间戳
         */
    }

    /*
     * 该方法将进入前台会调用
     */
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
            /*
             * 这个方法里判断锁屏的条件以及决定锁屏的界面显示
             */
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
```

***

## UIWindow的管理
【**简介**】UIWindow是 IOS 的窗口类，每一个 APP 显示都需要在窗口下才能显示出来；所以每个 APP 里都会有一个 mainWindow 作为该 APP 的显示窗口，也就是我们所设置的 keyWindow。不过注意的是可以在 UIApplication 这个单例里的 windows 这个数组里随意设置里面的 Window 为显示窗口。
对于实现锁屏的功能以及降低解决一些 APP 里需要保留现场的情况，可以考虑把锁屏界面，作为新窗口的根控制器进行设置。为了能比较快速准确的拿到该 Window ，可以考虑设置在*锁屏类*的单例中，作为该类的**属性**存在。
对于 Windows 的管理，需要注意的是系统自带的弹窗Alertcontroller、键盘keyboard都是作为独立的窗口弹出。所以在调试过程中最好查看UIApplication 这个单例里的 windows 数组，看看里面的情况。
实现锁屏对 UIWindow的管理结论如下：
- 创建一个独立显示的锁屏Window
- 将显示锁屏界面设置为该锁屏window 的根控制器
- 实现一个锁屏类，将该锁屏window作为该类的属性存在，以致该 window 不被释放

伪代码实现如下：
```swift
/// 后台锁屏枚举
///
/// - noLock: 在后台限定时间内不用解锁
/// - login: 超过一定时间需要登录
/// - locking: 需要解锁
public enum LockScreenType {
    case noLock
    case login
    case locking
}

public class LockScreenTool: UIWindow {

    static var enterBackgroundTime: NSTimeInterval = 0 //上一次进入后台时间
    private static let lockTime: NSTimeInterval = 60.0  //锁屏间隔时间  
    private static var window: UIWindow?
    
    //单例
    class func defaultWindow() -> UIWindow {
        if window == nil {
            window = UIWindow(frame: UIScreen.mainScreen().bounds)
        }
        return window!
    }   
     
   ...
 }
```

***

## 参考文档
- [iOS指纹解锁](http://www.jianshu.com/p/8ba83ec5688a)


