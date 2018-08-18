---
layout:     post
title:      OC对象中copy和mutableCopy方法详解
subtitle:   详解OC对象中copy和mutableCopy方法和注意事项
date:       2018-08-18
author:     Anyeler
header-img: img/post-bg-debug.png
catalog: true
tags:
    - iOS
    - Objective-C
    - 笔记
---


# 前言
前段时间，看到在*知识小集*的交流群里正在讨论 `copy` 和 `mutableCopy` 这两个方法的相关特性。而这两个方法的使用，对于 `Collection` 来说，确实在运行的时候会有些不一样。主要还是为了记录一下，避免以后忘记，所以写了这篇文章。


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
接下来的章节就是验证以上的结论的过程，不过这里需要注意的是验证过程中打印出来的类名都是 `NS*` 和 `NSMutable*` 的 **Class Clusters（类簇）**。
Apple 文档中是这样描述：

> an architecture that groups a number of private, concrete subclasses under a public, abstract superclass. （一个在共有的抽象超类下设置一组私有子类的架构）

`Class cluster` 是 Apple 对**抽象工厂设计模式**的称呼。使用**抽象类**初始化返回一个具体的子类的模式的好处就是让调用者只需要知道抽象类开放出来的API的作用，而不需要知道子类的背后复杂的逻辑。验证结论过程的类簇对应关系请看这篇 [Class Clusters 文档](https://gist.github.com/Catfish-Man/bc4a9987d4d7219043afdf8ee536beb2)。

## NSString
首先，验证字符串常量 `NSString` 调用 `copy` 和 `mutableCopy` 的情况。运行以下的测试代码：

```objc
NSString *str = @"abc"; // __NSCFConstantString
NSString *copyStr = [str copy]; // __NSCFConstantString
NSMutableString *mutableCopyStr = [str mutableCopy]; // __NSCFString

NSLog(@"str(%@<%p>: %p): %@", [str class], &str, str, str);
NSLog(@"copyStr(%@<%p>: %p): %@", [copyStr class], &copyStr, copyStr, copyStr);
NSLog(@"mutableCopyStr(%@<%p>: %p): %@", [mutableCopyStr class], &mutableCopyStr, mutableCopyStr, mutableCopyStr);
[mutableCopyStr appendString:@"add"];
NSLog(@"mutableCopyStr(%@<%p>: %p): %@", [mutableCopyStr class], &mutableCopyStr, mutableCopyStr, mutableCopyStr);
NSLog(@"end");
```

打印的结果如下：

```
2018-08-17 15:17:00.323254+0800 TestCocoOC[12366:898331] str(__NSCFConstantString<0x7ffee96d80c8>: 0x106529148): abc
2018-08-17 15:17:00.323383+0800 TestCocoOC[12366:898331] copyStr(__NSCFConstantString<0x7ffee96d80c0>: 0x106529148): abc
2018-08-17 15:17:00.323637+0800 TestCocoOC[12366:898331] mutableCopyStr(__NSCFString<0x7ffee96d80b8>: 0x60c000240870): abc
2018-08-17 15:17:00.323855+0800 TestCocoOC[12366:898331] mutableCopyStr(__NSCFString<0x7ffee96d80b8>: 0x60c000240870): abcadd
2018-08-17 15:17:00.323918+0800 TestCocoOC[12366:898331] end
```

Class Clusters 分析：
1. `__NSCFConstantString` 是字符串常量类，可看作 `NSString`。
2. `__NSCFString` 是字符串类，通常可看作 `NSMutableString`。

根据以上测试代码和打印的结果显示，可进行以下分析：
1. 变量 `str` 和 `copyStr` 打印出来的地址是相同的，都是 `0x106529148`而且类名相同，都是 `__NSCFConstantString`，说明只是浅拷贝，而且是 `NSString`。
2. 变量 `mutableCopyStr` 打印出的类名 `__NSCFString`，和其他的结果不一样，而且能够添加字符串，所以是 `NSMutableString`。  

根据以上验证可总结以下结果：

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSString | copy | NO | NSString | NO | NO | 浅拷贝 | NO |
|  | mutableCopy | YES | NSMutableString | NO | NO | 深拷贝 | NO |

## NSMutableString
**可变字符串**的 `copy` 和 `mutableCopy`操作，测试代码如下：

```objc
NSMutableString *str = [NSMutableString stringWithString:@"abc"]; // __NSCFString
NSMutableString *copyStr = [str copy]; //NSTaggedPointerString
NSMutableString *mutableCopyStr = [str mutableCopy]; // __NSCFString

NSLog(@"str(%@<%p>: %p): %@", [str class], &str, str, str);
NSLog(@"copyStr(%@<%p>: %p): %@", [copyStr class], &copyStr, copyStr, copyStr);
NSLog(@"mutableCopyStr(%@<%p>: %p): %@", [mutableCopyStr class], &mutableCopyStr, mutableCopyStr, mutableCopyStr);
NSLog(@"end");
```

打印的结果如下：

```
2018-08-17 13:39:26.601180+0800 TestCocoOC[9649:625978] str(__NSCFString<0x7ffeef6130c8>: 0x6000000599b0): abc
2018-08-17 13:39:26.601411+0800 TestCocoOC[9649:625978] copyStr(NSTaggedPointerString<0x7ffeef6130c0>: 0xa000000006362613): abc
2018-08-17 13:39:26.601701+0800 TestCocoOC[9649:625978] mutableCopyStr(__NSCFString<0x7ffeef6130b8>: 0x60000005ad00): abc
2018-08-17 13:39:26.602004+0800 TestCocoOC[9649:625978] end
```

Class Clusters 分析：
1. `NSTaggedPointerString` 是字符串常量类，可看作 `NSString`，这个类具备 `Tagged Pointer` 特性。
2. `__NSCFString` 是字符串类，通常可看作 `NSMutableString`。

根据打印的结果可得出以下分析：
1. `str`、`copyStr` 和 `mutableCopyStr` 指针指向的地址都是**不一样**的，说明都生成了新对象。
2. `copy` 方法生成**不可变字符串**对象，`mutableCopy` 方法生成的是**可变字符串**对象。

根据以上验证可总结以下结果：

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSMutableString | copy | YES | NSString | NO | NO | 深拷贝 | NO |
|  | mutableCopy | YES | NSMutableString | NO | NO | 深拷贝 | NO |

## NSArray
数组的拷贝操作，都是针对数组容器对象处理，数组里面的元素对象都是不变的。测试代码如下：

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

打印的结果如下：

```
2018-08-17 13:39:43.724273+0800 TestCocoOC[9649:625978] array(__NSArrayI<0x7ffeef613090>: 0x60c00024c3f0): (
"<Person: 0x60c0004246c0>",
"<Person: 0x60c000421ae0>",
"<Person: 0x60c000422ae0>"
)
2018-08-17 13:39:43.724481+0800 TestCocoOC[9649:625978] copyArray(__NSArrayI<0x7ffeef613088>: 0x60c00024c3f0): (
"<Person: 0x60c0004246c0>",
"<Person: 0x60c000421ae0>",
"<Person: 0x60c000422ae0>"
)
2018-08-17 13:39:43.724713+0800 TestCocoOC[9649:625978] mutableCopyArray(__NSArrayM<0x7ffeef613080>: 0x60c00024c2a0): (
"<Person: 0x60c0004246c0>",
"<Person: 0x60c000421ae0>",
"<Person: 0x60c000422ae0>"
)
2018-08-17 13:39:43.724984+0800 TestCocoOC[9649:625978] end
```

Class Clusters 分析：
1. `__NSArrayI` 是不可变数组子类，可看作 `NSArray`。
2. `__NSArrayM` 是可变数组子类，通常可看作 `NSMutableArray`。

根据以上测试代码和打印的结果显示，可进行以下分析：
1. 变量 `array` 和 `copyArray` 打印出来的地址是相同的，都是 `0x60c00024c3f0`而且类名相同，都是 `__NSArrayI`，说明只是浅拷贝，而且是 `NSArray`。
2. 变量 `mutableCopyStr` 打印出的类名 `__NSArrayM`，所以是 `NSMutableArray`。 
3. 数组里的元素打印的对象地址都是一样的。

根据以上验证可总结以下结果：

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSArray | copy | NO | NSArray | NO | NO | 浅拷贝 | NO |
|  | mutableCopy | YES | NSMutableArray | NO | NO | 深拷贝 | NO |

## NSMutableArray
不可变数组和可变数组的关系其实是子类和父类的关系。以下就是验证可变数组拷贝操作的测试代码：

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

打印的结果如下：

```
2018-08-17 13:41:31.266514+0800 TestCocoOC[9649:625978] array(__NSArrayM<0x7ffeef613090>: 0x6040002440b0): (
"<Person: 0x604000039460>",
"<Person: 0x6040000392c0>",
"<Person: 0x6040000391c0>"
)
2018-08-17 13:41:31.266738+0800 TestCocoOC[9649:625978] copyArray(__NSArrayI<0x7ffeef613088>: 0x604000243d20): (
"<Person: 0x604000039460>",
"<Person: 0x6040000392c0>",
"<Person: 0x6040000391c0>"
)
2018-08-17 13:41:31.267018+0800 TestCocoOC[9649:625978] mutableCopyArray(__NSArrayM<0x7ffeef613080>: 0x604000242820): (
"<Person: 0x604000039460>",
"<Person: 0x6040000392c0>",
"<Person: 0x6040000391c0>"
)
2018-08-17 13:41:31.267208+0800 TestCocoOC[9649:625978] end
```

Class Clusters 分析：
1. `__NSArrayI` 是不可变数组子类，可看作 `NSArray`。
2. `__NSArrayM` 是可变数组子类，通常可看作 `NSMutableArray`。

根据以上测试代码和打印的结果显示，可进行以下分析：
1. 变量 `array`、`copyArray` 和 `mutableCopyArray` 打印出来的地址是**不相同**的，说明都是容器的深拷贝。
2. 数组里的元素打印的对象地址都是一样的。  

根据以上验证可总结以下结果：

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSMutableArray | copy | YES | NSArray | NO | NO | 深拷贝 | NO |
|  | mutableCopy | YES | NSMutableArray | NO | NO | 深拷贝 | NO |

## NSDictionary
`key-value` 其实就是 Hash 表，里面的 `key` 都是**字符串常量**。当然，拷贝操作也不会对元素做处理。验证拷贝特性的测试代码如下：

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

打印的结果如下：

```
2018-08-17 13:41:48.389669+0800 TestCocoOC[9649:625978] dict(__NSDictionaryI<0x7ffeef613088>: 0x6000000730c0): {
key = qwe;
num = 1;
person = "<Person: 0x600000037da0>";
}
2018-08-17 13:41:48.389843+0800 TestCocoOC[9649:625978] copyDict(__NSDictionaryI<0x7ffeef613080>: 0x6000000730c0): {
key = qwe;
num = 1;
person = "<Person: 0x600000037da0>";
}
2018-08-17 13:41:48.390006+0800 TestCocoOC[9649:625978] mutableCopyDict(__NSDictionaryM<0x7ffeef613078>: 0x600000036900): {
key = qwe;
num = 1;
person = "<Person: 0x600000037da0>";
}
2018-08-17 13:41:48.390375+0800 TestCocoOC[9649:625978] end
```

Class Clusters 分析：
1. `__NSDictionaryI` 是不可变字典子类，可看作 `NSDictionary`。
2. `__NSDictionaryM` 是可变字典子类，通常可看作 `NSMutableDictionary`。

根据以上测试代码和打印的结果显示，可进行以下分析：
1. 变量 `dict` 和 `copyDict` 打印出来的地址是相同的，都是 `0x6000000730c0`而且类名相同，都是 `__NSDictionaryI`，说明只是浅拷贝，而且是 `NSDictionary`。
2. 变量 `mutableCopyDict` 打印出的类名 `__NSDictionaryM`，所以是 `NSMutableDictionary`。
3. 打印出来的元素对象（Person）地址都是一样的。

根据以上验证可总结以下结果：

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSDictionary | copy | NO | NSDictionary | NO | NO | 浅拷贝 | NO |
|  | mutableCopy | YES | NSMutableDictionary | NO | NO | 深拷贝 | NO |

## NSMutableDictionary
可变字典类的验证拷贝操作的测试代码如下：

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

打印的结果如下：

```
2018-08-17 13:42:18.754223+0800 TestCocoOC[9649:625978] dict(__NSDictionaryM<0x7ffeef613088>: 0x604000039040): {
key = qwe;
num = 1;
person = "<Person: 0x6040000391e0>";
}
2018-08-17 13:42:18.754484+0800 TestCocoOC[9649:625978] copyDict(__NSFrozenDictionaryM<0x7ffeef613080>: 0x6040000392c0): {
key = qwe;
num = 1;
person = "<Person: 0x6040000391e0>";
}
2018-08-17 13:42:18.754631+0800 TestCocoOC[9649:625978] mutableCopyDict(__NSDictionaryM<0x7ffeef613078>: 0x604000039400): {
key = qwe;
num = 1;
person = "<Person: 0x6040000391e0>";
}
2018-08-17 13:42:18.754877+0800 TestCocoOC[9649:625978] end
```

Class Clusters 分析：
1. `__NSDictionaryI` 是不可变字典子类，可看作 `NSDictionary`。
2. `__NSFrozenDictionaryM` 是**可变字典类**的副本类，可看作 `NSDictionary`。
3. `__NSDictionaryM` 是可变字典子类，通常可看作 `NSMutableDictionary`。

根据以上测试代码和打印的结果显示，可进行以下分析：
1. 变量 `dict`、`copyDict` 和 `mutableCopyDict` 打印出来的地址是**不相同**的，说明都是容器的深拷贝。
2. 打印出来的元素对象（Person）地址都是一样的。

根据以上验证可总结以下结果：

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSMutableDictionary | copy | YES | NSDictionary | NO | NO | 深拷贝 | NO |
|  | mutableCopy | YES | NSMutableDictionary | NO | NO | 深拷贝 | NO |

## NSSet
不可变去重无序集合，里面的元素都是唯一的。验证拷贝操作的测试代码如下：

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

打印的结果如下：

```
2018-08-17 13:43:29.316827+0800 TestCocoOC[9813:648649] set(__NSSetI<0x7ffee4e07090>: 0x60400024d5c0): {(
<Person: 0x60400003b360>,
<Person: 0x60400003b280>,
<Person: 0x60400003b1e0>
)}
2018-08-17 13:43:29.316999+0800 TestCocoOC[9813:648649] copySet(__NSSetI<0x7ffee4e07088>: 0x60400024d5c0): {(
<Person: 0x60400003b360>,
<Person: 0x60400003b280>,
<Person: 0x60400003b1e0>
)}
2018-08-17 13:43:29.317350+0800 TestCocoOC[9813:648649] mutableCopySet(__NSSetM<0x7ffee4e07080>: 0x60400003b0e0): {(
<Person: 0x60400003b360>,
<Person: 0x60400003b280>,
<Person: 0x60400003b1e0>
)}
2018-08-17 13:43:29.317455+0800 TestCocoOC[9813:648649] end
```

Class Clusters 分析：
1. `__NSSetI` 是不可变去重无序集合子类，可看作 `NSSet`。
2. `__NSSetM` 是可变去重无序集合子类，通常可看作 `NSMutableSet`。

根据以上测试代码和打印的结果显示，可进行以下分析：
1. 变量 `set` 和 `copySet` 打印出来的地址是相同的，都是 `0x60400024d5c0`而且类名相同，都是 `__NSSetI`，说明只是浅拷贝，而且是 `NSSet`。
2. 变量 `mutableCopySet` 打印出的类名 `__NSSetM`，所以是 `NSMutableSet`。
3. 打印出来的元素对象（Person）地址都是一样的。

根据以上验证可总结以下结果：

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSSet | copy | NO | NSSet | NO | NO | 浅拷贝 | NO |
|  | mutableCopy | YES | NSMutableSet | NO | NO | 深拷贝 | NO |

## NSMutableSet
可变去重无序集合，里面的元素都是唯一的。验证拷贝操作的测试代码如下：

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

打印的结果如下：

```
2018-08-17 13:43:52.278444+0800 TestCocoOC[9813:648649] set(__NSSetM<0x7ffee4e07090>: 0x60400003b360): {(
<Person: 0x60400003b2a0>,
<Person: 0x60400003b040>,
<Person: 0x60400003b160>
)}
2018-08-17 13:43:52.278611+0800 TestCocoOC[9813:648649] copySet(__NSSetI<0x7ffee4e07088>: 0x60400024dd10): {(
<Person: 0x60400003b2a0>,
<Person: 0x60400003b040>,
<Person: 0x60400003b160>
)}
2018-08-17 13:43:52.278686+0800 TestCocoOC[9813:648649] mutableCopySet(__NSSetM<0x7ffee4e07080>: 0x60400003b140): {(
<Person: 0x60400003b2a0>,
<Person: 0x60400003b040>,
<Person: 0x60400003b160>
)}
2018-08-17 13:43:52.279086+0800 TestCocoOC[9813:648649] end
```

Class Clusters 分析：
1. `__NSSetI` 是不可变去重无序集合子类，可看作 `NSSet`。
2. `__NSSetM` 是可变去重无序集合子类，通常可看作 `NSMutableSet`。

根据以上测试代码和打印的结果显示，可进行以下分析：
1. 变量 `set`、`copySet` 和 `mutableCopySet` 打印出来的地址是**不相同**的，说明都是容器的深拷贝。
2. 数组里的元素打印的对象地址都是一样的。  

根据以上验证可总结以下结果：

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSMutableSet | copy | YES | NSSet | NO | NO | 深拷贝 | NO |
|  | mutableCopy | YES | NSMutableSet | NO | NO | 深拷贝 | NO |

# 结论分析
上一节的验证结果符合**结论概括**所描述的。虽然验证过程输出的类比较复杂，Apple 引进了 `Class Clusters` 和 `Tagged Pointer` 的设计思想，但是还是这不妨碍拷贝操作的总结。不过有时间的话还是研究一下这两个设计思想，对以后设计架构会大有进步。
根据这篇文章的**结论概括**，在日常开发中可注意以下几点：
1. Objective-C 类中的属性，`NSMutable` 开头的**可变集合类**属性不要用 `copy` 关键字去修饰，以为每次赋值操作拷贝出来的都是**不可变集合类**了。
2. `Collection` 类`copy` 和 `mutableCopy` 方法，集合里面的元素对象都不会发生拷贝操作。简单的来说，只是对容器操作。
3. 自定义类的拷贝操作是自己控制的。

