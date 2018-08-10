---
layout:     post
title:      Objective-C对象的TaggedPointer特性
subtitle:   以NSString和NSNumber的为例解析TaggedPointer特性
date:       2018-08-11
author:     Anyeler
header-img: img/post-bg-debug.png
catalog: true
tags:
    - iOS
    - Objective-C
---


# 前言
前段时间，看到在*知识小集*的交流群里正在讨论 `copy` 和 `mutableCopy` 的相关特性。所以自己写了一个 *Demo* 验证一下群里提供的表是否正确。后来发现了 `NSString` 出现了**中间类**的情况。所以，写了这篇文章，记录一下。


# NSString 解析
在 iOS 开发中字符串的使用通常用的比较多的是 `NSString` 而不是 `char`。而对于这个 `NSString` 类，实际上在编译和运行的时候会转化为不同的类型。所以接下来，就需要了解一下这些相关类：`NSString`、`NSMutableString`、`__NSCFConstantString`、`__NSCFString`、`NSTaggedPointerString`。

## NSString 相关类说明表格

| 类名 | 存储区域 | 初始化的引用计数（retainCount） | 作用描述 |
| :-: | :-: | :-: | :-: |
| NSString | 堆区 | 1 | 开发者常用的不可变字符串类，编译期间会转换到其他类型 |
| NSMutableString | 堆区 | 1 | 开发者常用的可变字符串类，编译期间会转换到其他类型 |
| __NSCFString | 堆区 | 1 | 可变字符串 NSMutableString 类，编译期间会转换到该类型 |
| __NSCFConstantString | 堆区 | 2^64-1 | 不可变字符串 NSString 类，编译期间会转换到该类型 |
| NSTaggedPointerString | 栈区 | 2^64-1 | Tagged Pointer对象，并不是真的对象 |


## 测试代码
测试代码主要分为两部分：`NSString` 和 `NSMutableString`。当然，会通过这两部分代码说明问题。

### NSString 测试代码
首先，执行 *NSString* 的测试代码，如下：

```objc
NSString *str = @"abc"; // __NSCFConstantString
NSString *str1 = @"abc"; //__NSCFConstantString
NSString *str2 = [NSString stringWithFormat:@"%@", str]; // NSTaggedPointerString
NSString *str3 = [str copy]; // __NSCFConstantString
NSString *str4 = [str mutableCopy]; // __NSCFString
    
NSLog(@"str(%@<%p>: %p): %@", [str class], &str, str, str);
NSLog(@"str1(%@<%p>: %p): %@", [str1 class], &str1, str1, str1);
NSLog(@"str2(%@<%p>: %p): %@", [str2 class], &str2, str2, str2);
NSLog(@"str3(%@<%p>: %p): %@", [str3 class], &str3, str3, str3);
NSLog(@"str4(%@<%p>: %p): %@", [str4 class], &str4, str4, str4);
```

变量内存分布截图：

![NSString变量状态](https://alpics-1251916310.file.myqcloud.com/article/2018-08-10-1533907303005.jpg)

打印的结果如下：

```shell
2018-08-10 19:35:59.172724+0800 TestCocoaPods[3527:192649] str(__NSCFConstantString<0x7ffeecbe5ba8>: 0x10301c090): abc
2018-08-10 19:35:59.173112+0800 TestCocoaPods[3527:192649] str1(__NSCFConstantString<0x7ffeecbe5ba0>: 0x10301c090): abc
2018-08-10 19:35:59.173445+0800 TestCocoaPods[3527:192649] str2(NSTaggedPointerString<0x7ffeecbe5b98>: 0xa000000006362613): abc
2018-08-10 19:35:59.173616+0800 TestCocoaPods[3527:192649] str3(__NSCFConstantString<0x7ffeecbe5b90>: 0x10301c090): abc
2018-08-10 19:35:59.173845+0800 TestCocoaPods[3527:192649] str4(__NSCFString<0x7ffeecbe5b88>: 0x600000259050): abc
```

### NSMutableString 测试代码
接下来，执行 *NSMutableString* 的测试代码，如下：

```objc
NSMutableString *str = [NSMutableString stringWithString:@"abc"];
NSMutableString *str1 = [NSMutableString stringWithString:@"abc"];
NSMutableString *str2 = [NSMutableString stringWithFormat:@"%@", str];
NSMutableString *str3 = [str copy];
NSMutableString *str4 = [str mutableCopy];
    
NSLog(@"str(%@<%p>: %p): %@", [str class], &str, str, str);
NSLog(@"str1(%@<%p>: %p): %@", [str1 class], &str1, str1, str1);
NSLog(@"str2(%@<%p>: %p): %@", [str2 class], &str2, str2, str2);
NSLog(@"str3(%@<%p>: %p): %@", [str3 class], &str3, str3, str3);
NSLog(@"str4(%@<%p>: %p): %@", [str4 class], &str4, str4, str4);
```

变量内存分布截图：

![NSMutableString变量状态](https://alpics-1251916310.file.myqcloud.com/article/2018-08-10-1533908443894.jpg)

打印的结果如下：

```shell
2018-08-10 21:37:49.709725+0800 TestCocoaPods[4309:248326] str(__NSCFString<0x7ffeed8e6ba8>: 0x60000044f6c0): abc
2018-08-10 21:37:49.709956+0800 TestCocoaPods[4309:248326] str1(__NSCFString<0x7ffeed8e6ba0>: 0x600000450290): abc
2018-08-10 21:37:49.710309+0800 TestCocoaPods[4309:248326] str2(__NSCFString<0x7ffeed8e6b98>: 0x600000450740): abc
2018-08-10 21:37:49.710652+0800 TestCocoaPods[4309:248326] str3(NSTaggedPointerString<0x7ffeed8e6b90>: 0xa000000006362613): abc
2018-08-10 21:37:49.711494+0800 TestCocoaPods[4309:248326] str4(__NSCFString<0x7ffeed8e6b88>: 0x6000004506e0): abc
```

## 相关类的继承链条
以上所说的*字符串*的相关类，它们有什么关系呢？或者说有什么关联呢？这一节主要围绕这两个问题展开。由以上的测试代码和测试结果可以推断出*字符串类*的继承链条如下：

`__NSCFConstantString` -> `__NSCFString` -> `NSMutableString` -> `NSString` -> `NSObject`

其中，编译后的 `NSString` 一般实际使用的是 `__NSCFConstantString`，编译后的 `NSMutableString` 一般实际是使用 `__NSCFString`。所以，开发者只要了解其对应关系就可以了。从**测试代码**中打印的结果看还有一种类：`NSTaggedPointerString`。这是干嘛的呢？其实严格地说，这并不是一个类，它是适用于 `64位处理器` 的一个内存优化机制，也就是 `Tagged Pointer`。
接下来，将从 [**CoreFoundation**](https://github.com/nst/iOS-Runtime-Headers/tree/f53e3d01aceb4aab6ec2c37338d2df992d917536/Frameworks/CoreFoundation.framework) 露出来的头文件进行分析。

### __NSCFConstantString 字符串常量
在编译期间，就已经决定 `NSString` -> `__NSCFConstantString`。所以同一个字符串常量在**堆区**只分配一个空间，并且 `retainCount` 为**最大**。也就是说**不会被释放掉**。该类的定义在 **CoreFoundation** 中的 [**__NSCFConstantString.h**](https://github.com/nst/iOS-Runtime-Headers/blob/f53e3d01aceb4aab6ec2c37338d2df992d917536/Frameworks/CoreFoundation.framework/__NSCFConstantString.h) 文件中。
**定义代码如下：**

```objc
@interface __NSCFConstantString : __NSCFString

- (id)autorelease;
- (id)copyWithZone:(struct _NSZone { }*)arg1;
- (bool)isNSCFConstantString__;
- (oneway void)release;
- (id)retain;
- (unsigned long long)retainCount;

@end
```

如上代码可知，`__NSCFConstantString` 是继承于 `__NSCFString`。也就是说，重复的声明同样内容的字符串常量，实际上指向的是同一个堆区地址，如**NSString测试代码**的以下几行：

```objc
NSString *str = @"abc"; // __NSCFConstantString
NSString *str1 = @"abc"; //__NSCFConstantString
```

打印出的结果对应如下：

```shell
2018-08-10 19:35:59.172724+0800 TestCocoaPods[3527:192649] str(__NSCFConstantString<0x7ffeecbe5ba8>: 0x10301c090): abc
2018-08-10 19:35:59.173112+0800 TestCocoaPods[3527:192649] str1(__NSCFConstantString<0x7ffeecbe5ba0>: 0x10301c090): abc
```

可以看出，打印出来的堆区地址都是 `0x10301c090`。

### __NSCFString 可变字符串
在编译期间，就已经决定 `NSMutableString` -> `__NSCFString`。所以一个可变字符串常量在**堆区**会分配一个空间，并且 `retainCount` 为 **1**，也就是说按正常对象的生命周期被释放。该类的定义在 **CoreFoundation** 中的 [**__NSCFString.h**](https://github.com/nst/iOS-Runtime-Headers/blob/f53e3d01aceb4aab6ec2c37338d2df992d917536/Frameworks/CoreFoundation.framework/__NSCFString.h)。
**定义代码如下：**

```objc
@interface __NSCFString : NSMutableString

...

@end
```

如上代码可知，`__NSCFString` 是继承于 `NSMutableString`。

### NSTaggedPointerString
在编译期间，已经会决定 `NSString` -> `NSTaggedPointerString`。值将存储在**指针空间**，也就是栈（Stack）区，并且 `retainCount` 为**最大**。不过要触发这样的类型转换，需要满足以下两个条件：
> - 64位处理器
> - 内容很少，栈区能够装得下

具体的内存分布请看 `Tagged Pointer`。


# NSNumber 解析
在 iOS 开发中，数字通常会使用 `NSNumber` 类进行封装**承载**。而对于这个 `NSNumber` 类，实际上在编译和运行的时候会转化为不同的类型。所以接下来，就需要了解一下这些相关类：`NSNumber`、`__NSCFNumber`、`NSValue`。

## NSNumber 相关类说明表格

| 类名 | 存储区域 | 初始化的引用计数（retainCount | 作用描述 |
| :-: | :-: | :-: | :-: |
| NSValue | 堆区 | 1 | 主要用于封装结构体 |
| NSNumber | 堆区 | 1 | 开发者常用的数字类，编译期间会转换到其他类型 |
| __NSCFNumber | 堆区、栈区 | 1、2^64-1 | 数字类 NSNumber 类，编译期间会转换到该类型，若是 Tagged Pointer 则在栈区，引用计数为 2^64-1 |


## 测试代码
执行**NSNumber**的测试代码：

```objc
NSNumber *num1 = @1;
NSNumber *num2 = @2;
NSNumber *num3 = @3;
NSNumber *num4 = @(3.1415927);
NSNumber *num5 = [num1 copy];
NSNumber *num6 = [num4 copy];
    
NSLog(@"num1(%@<%p>: %p): %@", [num1 class], &num1, num1, num1);
NSLog(@"num2(%@<%p>: %p): %@", [num2 class], &num2, num2, num2);
NSLog(@"num3(%@<%p>: %p): %@", [num3 class], &num3, num3, num3);
NSLog(@"num4(%@<%p>: %p): %@", [num4 class], &num4, num4, num4);
NSLog(@"num5(%@<%p>: %p): %@", [num5 class], &num5, num5, num5);
NSLog(@"num6(%@<%p>: %p): %@", [num6 class], &num6, num6, num6);
```

变量内存分布截图：

![NSNumber变量状态](https://alpics-1251916310.file.myqcloud.com/article/2018-08-10-WX20180810-235239.png)

打印的结果如下：

```shell
2018-08-10 23:55:08.025987+0800 TestCocoaPods[5422:331863] num1(__NSCFNumber<0x7ffee5c32b70>: 0xb000000000000012): 1
2018-08-10 23:55:08.026190+0800 TestCocoaPods[5422:331863] num2(__NSCFNumber<0x7ffee5c32b68>: 0xb000000000000022): 2
2018-08-10 23:55:08.026329+0800 TestCocoaPods[5422:331863] num3(__NSCFNumber<0x7ffee5c32b60>: 0xb000000000000032): 3
2018-08-10 23:55:08.026422+0800 TestCocoaPods[5422:331863] num4(__NSCFNumber<0x7ffee5c32b58>: 0x604000425be0): 3.1415927
2018-08-10 23:55:08.026516+0800 TestCocoaPods[5422:331863] num5(__NSCFNumber<0x7ffee5c32b50>: 0xb000000000000012): 1
2018-08-10 23:55:09.688991+0800 TestCocoaPods[5422:331863] num6(__NSCFNumber<0x7ffee5c32b48>: 0x604000425be0): 3.1415927
```

## 相关类的继承链条
以上所说的*数字*的相关类，它们有什么关系呢？或者说有什么关联呢？这一节主要围绕这两个问题展开。由以上的测试代码和测试结果可以推断出*数字类*的继承链条如下：

`__NSCFNumber` -> `NSNumber` -> `NSValue` -> `NSObject`

其中，编译后的 `NSNumber` 一般实际使用的是 `__NSCFNumber`。所以，开发者只要了解其对应关系就可以了。在 `Tagged Pointer` 机制中，和**字符串**不同的地方是没有对应的`Tagged Pointer`对象类型。
接下来，将从 [**CoreFoundation**](https://github.com/nst/iOS-Runtime-Headers/tree/f53e3d01aceb4aab6ec2c37338d2df992d917536/Frameworks/CoreFoundation.framework) 露出来的头文件进行分析。

### __NSCFNumber 数字类
在编译期间，就已经决定 `NSNumber` -> `__NSCFNumber`。所以同一个字符串常量在**堆区**会分配一个空间，并且 `retainCount` 为 **1**。该类的定义在 **CoreFoundation** 中的 [**__NSCFNumber.h**](https://github.com/nst/iOS-Runtime-Headers/blob/f53e3d01aceb4aab6ec2c37338d2df992d917536/Frameworks/CoreFoundation.framework/__NSCFNumber.h) 文件中。
**定义代码如下：**

```objc
@interface __NSCFNumber : NSNumber

+ (bool)automaticallyNotifiesObserversForKey:(id)arg1;

- (long long)_cfNumberType;
- (unsigned long long)_cfTypeID;
- (unsigned char)_getValue:(void*)arg1 forType:(long long)arg2;
- (bool)_isDeallocating;
- (long long)_reverseCompare:(id)arg1;
- (bool)_tryRetain;
- (bool)boolValue;
- (BOOL)charValue;
- (long long)compare:(id)arg1;
- (id)copyWithZone:(struct _NSZone { }*)arg1;
- (id)description;
- (id)descriptionWithLocale:(id)arg1;
- (double)doubleValue;
- (float)floatValue;
- (void)getValue:(void*)arg1;
- (unsigned long long)hash;
- (int)intValue;
- (long long)integerValue;
- (bool)isEqual:(id)arg1;
- (bool)isEqualToNumber:(id)arg1;
- (bool)isNSNumber__;
- (long long)longLongValue;
- (long long)longValue;
- (const char *)objCType;
- (oneway void)release;
- (id)retain;
- (unsigned long long)retainCount;
- (short)shortValue;
- (id)stringValue;
- (unsigned char)unsignedCharValue;
- (unsigned int)unsignedIntValue;
- (unsigned long long)unsignedIntegerValue;
- (unsigned long long)unsignedLongLongValue;
- (unsigned long long)unsignedLongValue;
- (unsigned short)unsignedShortValue;

@end
```

### __NSCFNumber 的 Tagged Pointer 特性
在编译期间，就已经决定 `NSNumber` -> `__NSCFNumber`。不过，需要启动 `Tagged Pointer` 的条件和字符串的 `NSTaggedPointerString`条件一样如下：
> - 64位处理器
> - 数字较小，栈区能够装得下


# Tagged Pointer 特性分析
为了改进从 *32位CPU* 迁移到 *64位CPU* 的**内存浪费和效率**问题，在 *64位CPU* 环境下，引入了 `Tagged Pointer` 对象。有了这样的机制，系统会对 `NSString`、`NSNumber` 和 `NSDate`等对象进行优化。

## 未引入 Tagged Pointer 内存分布
一般的 iOS 程序，从32位迁移到64位CPU，虽然逻辑上是不会有任何变化，但是所占有的内存空间就会**翻倍**。以 `NSInteger` 封装成 `NSNumber` 为例，内存分布图如下：

![未引入TaggedPointer内存分布图](https://alpics-1251916310.file.myqcloud.com/article/2018-08-10-OldTagged.png)

由分布图所示，占用内存从32位CPU的**12个字节**到**24个字节**整整翻了一倍。

## 引入 Tagged Pointer 内存分布
引用了 `Tagged Pointer` 的对象，节省了分配在堆区的空间，将值存在指针区域的栈区。从而节省了内存空间以及大大提升了访问速度。以 `NSInteger` 封装成 `NSNumber` 为例，内存分布图如下：

![引入TaggedPointer内存分布图](https://alpics-1251916310.file.myqcloud.com/article/2018-08-10-Tagged.png)

由分布图所示，占用内存从32位CPU的**12个字节**到**8个字节**，还节省了**3个字节**的内存空间。而且引用计数 `retainCount` 为**最大值**。

## 验证过程
根据以上**NSNumber**的测试代码：

```objc
NSNumber *num1 = @1;
NSNumber *num2 = @2;
NSNumber *num3 = @3;
NSNumber *num4 = @(3.1415927);
NSNumber *num5 = [num1 copy];
NSNumber *num6 = [num4 copy];
```

打印的结果如下：

```shell
2018-08-10 23:55:08.025987+0800 TestCocoaPods[5422:331863] num1(__NSCFNumber<0x7ffee5c32b70>: 0xb000000000000012): 1
2018-08-10 23:55:08.026190+0800 TestCocoaPods[5422:331863] num2(__NSCFNumber<0x7ffee5c32b68>: 0xb000000000000022): 2
2018-08-10 23:55:08.026329+0800 TestCocoaPods[5422:331863] num3(__NSCFNumber<0x7ffee5c32b60>: 0xb000000000000032): 3
2018-08-10 23:55:08.026422+0800 TestCocoaPods[5422:331863] num4(__NSCFNumber<0x7ffee5c32b58>: 0x604000425be0): 3.1415927
2018-08-10 23:55:08.026516+0800 TestCocoaPods[5422:331863] num5(__NSCFNumber<0x7ffee5c32b50>: 0xb000000000000012): 1
2018-08-10 23:55:09.688991+0800 TestCocoaPods[5422:331863] num6(__NSCFNumber<0x7ffee5c32b48>: 0x604000425be0): 3.1415927
```

说明使用 `Tagged Pointer` 的对象的值都会存储在指针的值里。以上打印结果，可看出 `0xb` 开头的地址都是 `Tagged Pointer`，只要把前面的 `0xb` 和 尾部的 `2`去掉，剩下的就是真正的值。具体的存储细节，可参考 [**tagged-pointers**](https://www.mikeash.com/pyblog/friday-qa-2012-07-27-lets-build-tagged-pointers.html) 文档。
而打印结果中的 `num4` 变量存储的是**双精度浮点数**，栈区存不了，所以会在堆区开辟空间存储。

## 特点总结
`Tagged Pointer` 的引用主要解决**内存浪费**和**访问效率**的问题。所以其有以下特点：
1. `Tagged Pointer` 专门用于存储**小**的对象，例如：`NSString`、`NSNumber` 和 `NSDate`。
2. `Tagged Pointer`指针的值不再是堆区地址，而是真正的值。所以，实际上它不再是一个对象了，它只是一个披着对象皮的普通变量而已。所以，它的内存并不存储在堆中，也不需要 `malloc` 和 `free`。
3. 在内存读取上有着 3 倍的效率，创建时比以前快 106 倍。

如此可见，Apple 引入了 `Tagged Pointer` 不仅仅节省了64位处理器的占用内存空间，还提高了运行效率。

## 使用注意点
`Tagged Pointer` 并不是真正的指针，由测试代码的**变量内存分布截图**，都可表明其对应的 `isa` 指针已经指向 `0x0` 地址。所以如果你直接访问 `Tagged Pointer` 的 `isa` 成员的话，编译时期将会有**警告**。可以通过调用 `isKindOfClass` 和 `object_getClass`，避免直接访问对象的 `isa` 变量。

# 结论
在iOS的日常开发中，**同样内容的字符串常量** `__NSCFConstantString` 全局只有一份，放在堆区，并且不会被释放（retainCount值最大）。并且由于有 `Tagged Pointer` 的存在，尽量避免**直接访问**对象的 `isa` 变量。

# 参考文档

- [**NSString特性分析学习**](https://blog.cnbluebox.com/blog/2014/04/16/nsstringte-xing-fen-xi-xue-xi/)

- [**NSString的内存管理**](http://skyfly.xyz/2015/11/08/iOS/NSString%E7%9A%84%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/)

- [**深入理解Tagged Pointer**](http://blog.devtang.com/2014/05/30/understand-tagged-pointer/)

- [**tagged-pointers**](https://www.mikeash.com/pyblog/friday-qa-2012-07-27-lets-build-tagged-pointers.html)

