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

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSMutableString | copy | YES | NSString | NO | NO | 深拷贝 | NO |
|  | mutableCopy | YES | NSMutableString | NO | NO | 深拷贝 | NO |

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

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSArray | copy | NO | NSArray | NO | NO | 浅拷贝 | NO |
|  | mutableCopy | YES | NSMutableArray | NO | NO | 深拷贝 | NO |

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

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSMutableArray | copy | YES | NSArray | NO | NO | 深拷贝 | NO |
|  | mutableCopy | YES | NSMutableArray | NO | NO | 深拷贝 | NO |

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

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSDictionary | copy | NO | NSDictionary | NO | NO | 浅拷贝 | NO |
|  | mutableCopy | YES | NSMutableDictionary | NO | NO | 深拷贝 | NO |

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

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSMutableDictionary | copy | YES | NSDictionary | NO | NO | 深拷贝 | NO |
|  | mutableCopy | YES | NSMutableDictionary | NO | NO | 深拷贝 | NO |

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

| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSSet | copy | NO | NSSet | NO | NO | 浅拷贝 | NO |
|  | mutableCopy | YES | NSMutableSet | NO | NO | 深拷贝 | NO |

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


| 类名 | 操作 | 新对象 | 新类名 | 新元素对象 | 调用旧元素对应的Copy方法 | 拷贝类型 | 元素拷贝 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| NSMutableSet | copy | YES | NSSet | NO | NO | 深拷贝 | NO |
|  | mutableCopy | YES | NSMutableSet | NO | NO | 深拷贝 | NO |

# 结论分析


