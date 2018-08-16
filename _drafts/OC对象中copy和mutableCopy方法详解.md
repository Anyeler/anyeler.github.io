# 目录
[TOC]


# 前言
前段时间，看到在*知识小集*的交流群里正在讨论 `copy` 和 `mutableCopy` 这两个方法的相关特性。而这两个方法的使用，对于 `Collection` 来说，确实在运行的时候会有些不一样。


# 理论概述
本文章将会讨论 `CoreFoundation` 和 `Foundation` 框架里面的 `Collection` 类，当然也会简单的讲述自己定义的类，怎么实现 `copy` 和 `mutableCopy` 方法。

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝方式 | 内容拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NS* | copy | NO | NS* | NO | NO | 浅拷贝 | NO |
|  | mutableCopy | YES | NSMutable* | NO | NO | 浅拷贝 | NO |
| NSMutable* | copy | YES | NS* | NO | NO | 浅拷贝 | NO |
|  | mutableCopy | YES | NSMutable* | NO | NO | 浅拷贝 | NO |



# 验证过程

## NSString

## NSMutableString

## NSArray

## NSMutableArray

## NSDictionary

## NSMutableDictionary

## NSSet

## NSMutableSet

# 结论分析

# 参考文档

