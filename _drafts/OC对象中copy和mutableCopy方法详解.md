# 目录
[TOC]


# 前言
前段时间，看到在*知识小集*的交流群里正在讨论 `copy` 和 `mutableCopy` 这两个方法的相关特性。而这两个方法的使用，对于 `Collection` 来说，确实在运行的时候会有些不一样。


# 理论概述
本文章将会讨论 `CoreFoundation` 和 `Foundation` 框架里面的 `Collection` 类，当然也会简单的讲述自己定义的类，怎么实现 `copy` 和 `mutableCopy` 方法。

## Collection 类的结论概括
首先，先查看有关 `Collection` 类的总结。当然，以下表格总结的结论只验证过一下这些类 `NSString`、`NSMutableString`、`NSArray`、`NSMutableArray`、`NSDictionary`、`NSMutableDictionary`、`NSSet` 和 `NSMutableSet`。

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NS* | copy | NO | NS* | NO | NO | 浅拷贝 | NO |
|  | mutableCopy | YES | NSMutable* | NO | NO | 深拷贝 | NO |
| NSMutable* | copy | YES | NS* | NO | NO | 深拷贝 | NO |
|  | mutableCopy | YES | NSMutable* | NO | NO | 深拷贝 | NO |

由以上表格可以得出以下结论：

> 1. `Collection` 类（容器）所有的 **Copy** 操作都只是对**容器**操作，不会对容器里的**元素**进行 **Copy** 操作。
> 
> 2. 只有 `NS` 开头的**不可变**字符串/数组/字典等集合类型调用 `copy` 方法才是**浅拷贝（指针拷贝）**，不会生成**新容器对象**；其余的情况，则是**深拷贝（内容拷贝）**，会生成对应的**新容器对象**，但容器内的元素还是原来的元素。
> 
> 3. 调用 `copy` 方法输出的是 `NS` 开头的**不可变**字符串/数组/字典等集合类型，调用 `mutableCopy` 方法输出的是 `NSMutable` 开头的**可变**字符串/数组/字典等集合类型（这里说的是输出的类型，不一定产生新容器对象）。


## 自定义类的结论概括
自定义类，调用 `copy` 和 `mutableCopy` 方法的**输出规则**其实主要还是看自己实现的代码控制。

需要自定义类实现 `copy` 方法，就必须遵守 `NSCopying` 协议，并实现 `- (id)copyWithZone:(NSZone *)zone` 方法，详情请看以下代码：

```objc
@interface Person : NSObject <NSCopying>

@end

@implementation Person

- (id)copyWithZone:(NSZone *)zone {
    //这里需要Copy操作返回什么，就会输出什么
    return self;
}

@end
```

需要自定义类实现 `mutableCopy` 方法，就必须遵守 `NSMutableCopying` 协议，并实现 `- (id)mutableCopyWithZone:(NSZone *)zone` 方法，详情请看以下代码：

```objc
@interface Person : NSObject <NSMutableCopying>

@end

@implementation Person

- (id)mutableCopyWithZone:(NSZone *)zone {
    //这里需要mutableCopy操作返回什么，就会输出什么
    return [[[self class] alloc] init];
}

@end
```


# 验证结论概括



## NSString

```objc
NSString *str = @"abc"; // __NSCFConstantString
NSString *copyStr = [str copy]; // __NSCFConstantString
NSMutableString *mutableCopyStr = [str mutableCopy]; // __NSCFString

NSLog(@"str(%@<%p>: %p): %@", [str class], &str, str, str);
NSLog(@"copyStr(%@<%p>: %p): %@", [copyStr class], &copyStr, copyStr, copyStr);
NSLog(@"mutableCopyStr(%@<%p>: %p): %@", [mutableCopyStr class], &mutableCopyStr, mutableCopyStr, mutableCopyStr);
NSLog(@"end");
```

## NSMutableString

```objc
NSMutableString *str = [NSMutableString stringWithString:@"abc"]; // __NSCFString
NSMutableString *copyStr = [str copy]; //NSTaggedPointerString
NSMutableString *mutableCopyStr = [str mutableCopy]; // __NSCFString

NSLog(@"str(%@<%p>: %p): %@", [str class], &str, str, str);
NSLog(@"copyStr(%@<%p>: %p): %@", [copyStr class], &copyStr, copyStr, copyStr);
NSLog(@"mutableCopyStr(%@<%p>: %p): %@", [mutableCopyStr class], &mutableCopyStr, mutableCopyStr, mutableCopyStr);
NSLog(@"end");
```

## NSArray

```objc
Person *person1 = [[Person alloc] init];
Person *person2 = [[Person alloc] init];
Person *person3 = [[Person alloc] init];
NSArray *array = @[person1, person2, person3]; //__NSArrayI
NSArray *copyArray = [array copy]; //__NSArrayI
NSArray *mutableCopyArray = [array mutableCopy]; //__NSArrayM

NSLog(@"array(%@<%p>: %p): %@", [array class], &array, array, array);
NSLog(@"copyArray(%@<%p>: %p): %@", [copyArray class], &copyArray, copyArray, copyArray);
NSLog(@"mutableCopyArray(%@<%p>: %p): %@", [mutableCopyArray class], &mutableCopyArray, mutableCopyArray, mutableCopyArray);
NSLog(@"end");
```

## NSMutableArray

```objc
Person *person1 = [[Person alloc] init];
Person *person2 = [[Person alloc] init];
Person *person3 = [[Person alloc] init];
NSMutableArray *array = [[NSMutableArray alloc] initWithArray:@[person1, person2, person3]]; // __NSArrayM
//NSMutableArray *array = [[NSMutableArray alloc] initWithArray:@[person1, person2, person3] copyItems:YES]; //初始化只做一次拷贝，会触发 Person 的 copy 方法
NSMutableArray *copyArray = [array copy]; //__NSArrayI
NSMutableArray *mutableCopyArray = [array mutableCopy]; //__NSArrayM
NSLog(@"array(%@<%p>: %p): %@", [array class], &array, array, array);
NSLog(@"copyArray(%@<%p>: %p): %@", [copyArray class], &copyArray, copyArray, copyArray);
NSLog(@"mutableCopyArray(%@<%p>: %p): %@", [mutableCopyArray class], &mutableCopyArray, mutableCopyArray, mutableCopyArray);
NSLog(@"end");
```

## NSDictionary

```objc
Person *person = [[Person alloc] init];
NSDictionary *dict = @{@"key":@"qwe",
                       @"num":@1,
                       @"person": person}; //__NSDictionaryI
NSDictionary *copyDict = [dict copy]; //__NSDictionaryI
NSDictionary *mutableCopyDict = [dict mutableCopy]; //__NSDictionaryM
NSLog(@"dict(%@<%p>: %p): %@", [dict class], &dict, dict, dict);
NSLog(@"copyDict(%@<%p>: %p): %@", [copyDict class], &copyDict, copyDict, copyDict);
NSLog(@"mutableCopyDict(%@<%p>: %p): %@", [mutableCopyDict class], &mutableCopyDict, mutableCopyDict, mutableCopyDict);
NSLog(@"end");
```

## NSMutableDictionary

```objc
Person *person = [[Person alloc] init];
NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"key":@"qwe",
                                                                            @"num":@1,
                                                                            @"person": person}]; // __NSDictionaryM
NSMutableDictionary *copyDict = [dict copy]; //__NSFrozenDictionaryM
NSMutableDictionary *mutableCopyDict = [dict mutableCopy]; //__NSDictionaryM
NSLog(@"dict(%@<%p>: %p): %@", [dict class], &dict, dict, dict);
NSLog(@"copyDict(%@<%p>: %p): %@", [copyDict class], &copyDict, copyDict, copyDict);
NSLog(@"mutableCopyDict(%@<%p>: %p): %@", [mutableCopyDict class], &mutableCopyDict, mutableCopyDict, mutableCopyDict);
NSLog(@"end");
```

## NSSet

```objc
Person *person1 = [[Person alloc] init];
Person *person2 = [[Person alloc] init];
Person *person3 = [[Person alloc] init];
NSSet *set = [[NSSet alloc] initWithArray:@[person1, person2, person3]]; // __NSSetI
NSSet *copySet = [set copy]; //__NSSetI
NSSet *mutableCopySet = [set mutableCopy]; //__NSSetM
NSLog(@"set(%@<%p>: %p): %@", [set class], &set, set, set);
NSLog(@"copySet(%@<%p>: %p): %@", [copySet class], &copySet, copySet, copySet);
NSLog(@"mutableCopySet(%@<%p>: %p): %@", [mutableCopySet class], &mutableCopySet, mutableCopySet, mutableCopySet);
NSLog(@"end");
```

## NSMutableSet

```objc
Person *person1 = [[Person alloc] init];
Person *person2 = [[Person alloc] init];
Person *person3 = [[Person alloc] init];
NSMutableSet *set = [[NSMutableSet alloc] initWithArray:@[person1, person2, person3]]; // __NSSetM
NSMutableSet *copySet = [set copy]; //__NSSetI
NSMutableSet *mutableCopySet = [set mutableCopy]; //__NSSetM
NSLog(@"set(%@<%p>: %p): %@", [set class], &set, set, set);
NSLog(@"copySet(%@<%p>: %p): %@", [copySet class], &copySet, copySet, copySet);
NSLog(@"mutableCopySet(%@<%p>: %p): %@", [mutableCopySet class], &mutableCopySet, mutableCopySet, mutableCopySet);
NSLog(@"end");
```

# 结论分析


