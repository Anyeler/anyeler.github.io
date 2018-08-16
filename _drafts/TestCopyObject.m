//
//  TestCopyObject.m
//  TestCocoaPods
//
//  Created by 张远文 on 2018/8/9.
//  Copyright © 2018年 张远文. All rights reserved.
//

#import "TestCopyObject.h"
#import "Person.h"

@implementation TestCopyObject

#pragma mark - String
+ (void)stringCopy {
    
    NSString *str = @"abc"; // __NSCFConstantString
    NSString *copyStr = [str copy]; // __NSCFConstantString
    NSMutableString *mutableCopyStr = [str mutableCopy]; // __NSCFString

    NSLog(@"str(%@<%p>: %p): %@", [str class], &str, str, str);
    NSLog(@"copyStr(%@<%p>: %p): %@", [copyStr class], &copyStr, copyStr, copyStr);
    NSLog(@"mutableCopyStr(%@<%p>: %p): %@", [mutableCopyStr class], &mutableCopyStr, mutableCopyStr, mutableCopyStr);
    [mutableCopyStr appendString:@"dddd"];
    NSLog(@"mutableCopyStr(%@<%p>: %p): %@", [mutableCopyStr class], &mutableCopyStr, mutableCopyStr, mutableCopyStr);
    /*
     2018-08-11 17:01:43.894144+0800 TestCocoaPods[1659:91031] str(__NSCFConstantString<0x7ffeeb12eb98>: 0x104ad3090): abc
     2018-08-11 17:01:49.090064+0800 TestCocoaPods[1659:91031] copyStr(__NSCFConstantString<0x7ffeeb12eb90>: 0x104ad3090): abc
     2018-08-11 17:01:49.090263+0800 TestCocoaPods[1659:91031] mutableCopyStr(__NSCFString<0x7ffeeb12eb88>: 0x60400025f740): abc
     2018-08-11 17:01:49.090412+0800 TestCocoaPods[1659:91031] mutableCopyStr(__NSCFString<0x7ffeeb12eb88>: 0x60400025f740): abcdddd
     2018-08-11 17:02:46.822090+0800 TestCocoaPods[1659:91031] end
     */
    NSLog(@"end");
}

+ (void)mutableStringCopy {
    NSMutableString *str = [NSMutableString stringWithString:@"abc"]; // __NSCFString
    NSMutableString *copyStr = [str copy]; //NSTaggedPointerString
    NSMutableString *mutableCopyStr = [str mutableCopy]; // __NSCFString

    NSLog(@"str(%@<%p>: %p): %@", [str class], &str, str, str);
    NSLog(@"copyStr(%@<%p>: %p): %@", [copyStr class], &copyStr, copyStr, copyStr);
    NSLog(@"mutableCopyStr(%@<%p>: %p): %@", [mutableCopyStr class], &mutableCopyStr, mutableCopyStr, mutableCopyStr);
    /*
     2018-08-11 17:03:47.422012+0800 TestCocoaPods[1701:93195] str(__NSCFString<0x7ffee8aa1b98>: 0x6040002481c0): abc
     2018-08-11 17:03:47.422385+0800 TestCocoaPods[1701:93195] copyStr(NSTaggedPointerString<0x7ffee8aa1b90>: 0xa000000006362613): abc
     2018-08-11 17:03:47.423098+0800 TestCocoaPods[1701:93195] mutableCopyStr(__NSCFString<0x7ffee8aa1b88>: 0x604000243d50): abc
     2018-08-11 17:04:00.721704+0800 TestCocoaPods[1701:93195] end
     */
    NSLog(@"end");
}

#pragma mark - Array
+ (void)arrayCopy {
    Person *person1 = [[Person alloc] init];
    Person *person2 = [[Person alloc] init];
    Person *person3 = [[Person alloc] init];
    NSArray *array = @[person1, person2, person3]; //__NSArrayI
    NSArray *copyArray = [array copy]; //__NSArrayI
    NSArray *mutableCopyArray = [array mutableCopy]; //__NSArrayM

    NSLog(@"array(%@<%p>: %p): %@", [array class], &array, array, array);
    NSLog(@"copyArray(%@<%p>: %p): %@", [copyArray class], &copyArray, copyArray, copyArray);
    NSLog(@"mutableCopyArray(%@<%p>: %p): %@", [mutableCopyArray class], &mutableCopyArray, mutableCopyArray, mutableCopyArray);
    /*
     2018-08-11 17:05:29.188536+0800 TestCocoaPods[1732:94643] array(__NSArrayI<0x7ffee8eb9b60>: 0x604000459d40): (
     "<Person: 0x60400043aa60>",
     "<Person: 0x60400043ab20>",
     "<Person: 0x604000437f60>"
     )
     2018-08-11 17:05:29.188959+0800 TestCocoaPods[1732:94643] copyArray(__NSArrayI<0x7ffee8eb9b58>: 0x604000459d40): (
     "<Person: 0x60400043aa60>",
     "<Person: 0x60400043ab20>",
     "<Person: 0x604000437f60>"
     )
     2018-08-11 17:05:29.189282+0800 TestCocoaPods[1732:94643] mutableCopyArray(__NSArrayM<0x7ffee8eb9b50>: 0x60400045b180): (
     "<Person: 0x60400043aa60>",
     "<Person: 0x60400043ab20>",
     "<Person: 0x604000437f60>"
     )
     2018-08-11 17:05:41.823298+0800 TestCocoaPods[1732:94643] end
     */
    NSLog(@"end");
}

+ (void)mutableArrayCopy {
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
    /*
     2018-08-11 17:08:11.221305+0800 TestCocoaPods[1732:94643] array(__NSArrayM<0x7ffee8eb9b60>: 0x600000249a50): (
     "<Person: 0x600000228be0>",
     "<Person: 0x6000002277a0>",
     "<Person: 0x600000229a80>"
     )
     2018-08-11 17:08:11.221570+0800 TestCocoaPods[1732:94643] copyArray(__NSArrayI<0x7ffee8eb9b58>: 0x600000247440): (
     "<Person: 0x600000228be0>",
     "<Person: 0x6000002277a0>",
     "<Person: 0x600000229a80>"
     )
     2018-08-11 17:08:25.024713+0800 TestCocoaPods[1732:94643] mutableCopyArray(__NSArrayM<0x7ffee8eb9b50>: 0x600000248a00): (
     "<Person: 0x600000228be0>",
     "<Person: 0x6000002277a0>",
     "<Person: 0x600000229a80>"
     )
     2018-08-11 17:08:26.580920+0800 TestCocoaPods[1732:94643] end
     */
    NSLog(@"end");
}

#pragma mark - Dictionary
+ (void)dictionaryCopy {
    Person *person = [[Person alloc] init];
    NSDictionary *dict = @{@"key":@"qwe",
                           @"num":@1,
                           @"person": person}; //__NSDictionaryI
    NSDictionary *copyDict = [dict copy]; //__NSDictionaryI
    NSDictionary *mutableCopyDict = [dict mutableCopy]; //__NSDictionaryM
    NSLog(@"dict(%@<%p>: %p): %@", [dict class], &dict, dict, dict);
    NSLog(@"copyDict(%@<%p>: %p): %@", [copyDict class], &copyDict, copyDict, copyDict);
    NSLog(@"mutableCopyDict(%@<%p>: %p): %@", [mutableCopyDict class], &mutableCopyDict, mutableCopyDict, mutableCopyDict);
    /*
     2018-08-11 17:14:42.739333+0800 TestCocoaPods[1871:101535] dict(__NSDictionaryI<0x7ffee062cb58>: 0x600000478b80): {
     key = qwe;
     num = 1;
     person = "<Person: 0x6000002206a0>";
     }
     2018-08-11 17:14:42.739548+0800 TestCocoaPods[1871:101535] copyDict(__NSDictionaryI<0x7ffee062cb50>: 0x600000478b80): {
     key = qwe;
     num = 1;
     person = "<Person: 0x6000002206a0>";
     }
     2018-08-11 17:14:44.296440+0800 TestCocoaPods[1871:101535] mutableCopyDict(__NSDictionaryM<0x7ffee062cb48>: 0x60000003f4c0): {
     key = qwe;
     num = 1;
     person = "<Person: 0x6000002206a0>";
     }
     2018-08-11 17:14:45.327236+0800 TestCocoaPods[1871:101535] end
     */
    NSLog(@"end");
}

+ (void)mutableDictionaryCopy {
    Person *person = [[Person alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"key":@"qwe",
                                                                                @"num":@1,
                                                                                @"person": person}]; // __NSDictionaryM
    NSMutableDictionary *copyDict = [dict copy]; //__NSFrozenDictionaryM
    NSMutableDictionary *mutableCopyDict = [dict mutableCopy]; //__NSDictionaryM
    NSLog(@"dict(%@<%p>: %p): %@", [dict class], &dict, dict, dict);
    NSLog(@"copyDict(%@<%p>: %p): %@", [copyDict class], &copyDict, copyDict, copyDict);
    NSLog(@"mutableCopyDict(%@<%p>: %p): %@", [mutableCopyDict class], &mutableCopyDict, mutableCopyDict, mutableCopyDict);
    /*
     dict(__NSDictionaryM<0x7ffee30b3b58>: 0x604000222960): {
     key = qwe;
     num = 1;
     person = "<Person: 0x6040002226c0>";
     }
     2018-08-11 17:16:04.688964+0800 TestCocoaPods[1921:103809] copyDict(__NSFrozenDictionaryM<0x7ffee30b3b50>: 0x604000221d00): {
     key = qwe;
     num = 1;
     person = "<Person: 0x6040002226c0>";
     }
     2018-08-11 17:16:04.689106+0800 TestCocoaPods[1921:103809] mutableCopyDict(__NSDictionaryM<0x7ffee30b3b48>: 0x604000220880): {
     key = qwe;
     num = 1;
     person = "<Person: 0x6040002226c0>";
     }
     2018-08-11 17:16:16.689941+0800 TestCocoaPods[1921:103809] end
     */
    NSLog(@"end");
}

#pragma mark - Set
+ (void)setCopy {
    Person *person1 = [[Person alloc] init];
    Person *person2 = [[Person alloc] init];
    Person *person3 = [[Person alloc] init];
    NSSet *set = [[NSSet alloc] initWithArray:@[person1, person2, person3]]; // __NSSetI
    NSSet *copySet = [set copy]; //__NSSetI
    NSSet *mutableCopySet = [set mutableCopy]; //__NSSetM
    NSLog(@"set(%@<%p>: %p): %@", [set class], &set, set, set);
    NSLog(@"copySet(%@<%p>: %p): %@", [copySet class], &copySet, copySet, copySet);
    NSLog(@"mutableCopySet(%@<%p>: %p): %@", [mutableCopySet class], &mutableCopySet, mutableCopySet, mutableCopySet);
    /*
     2018-08-11 17:17:54.837796+0800 TestCocoaPods[1957:105457] set(__NSSetI<0x7ffee8bc1b60>: 0x60400044ad10): {(
     <Person: 0x60400043a540>,
     <Person: 0x60400043a1e0>,
     <Person: 0x60400043aaa0>
     )}
     2018-08-11 17:17:54.838031+0800 TestCocoaPods[1957:105457] copySet(__NSSetI<0x7ffee8bc1b58>: 0x60400044ad10): {(
     <Person: 0x60400043a540>,
     <Person: 0x60400043a1e0>,
     <Person: 0x60400043aaa0>
     )}
     2018-08-11 17:17:54.838305+0800 TestCocoaPods[1957:105457] mutableCopySet(__NSSetM<0x7ffee8bc1b50>: 0x60400043a880): {(
     <Person: 0x60400043a540>,
     <Person: 0x60400043a1e0>,
     <Person: 0x60400043aaa0>
     )}
     2018-08-11 17:17:54.838425+0800 TestCocoaPods[1957:105457] end
     */
    NSLog(@"end");
}

+ (void)mutableSetCopy {
    Person *person1 = [[Person alloc] init];
    Person *person2 = [[Person alloc] init];
    Person *person3 = [[Person alloc] init];
    NSMutableSet *set = [[NSMutableSet alloc] initWithArray:@[person1, person2, person3]]; // __NSSetM
    NSMutableSet *copySet = [set copy]; //__NSSetI
    NSMutableSet *mutableCopySet = [set mutableCopy]; //__NSSetM
    NSLog(@"set(%@<%p>: %p): %@", [set class], &set, set, set);
    NSLog(@"copySet(%@<%p>: %p): %@", [copySet class], &copySet, copySet, copySet);
    NSLog(@"mutableCopySet(%@<%p>: %p): %@", [mutableCopySet class], &mutableCopySet, mutableCopySet, mutableCopySet);
    /*
     2018-08-11 17:19:13.430827+0800 TestCocoaPods[1957:105457] set(__NSSetM<0x7ffee8bc1b60>: 0x6000002316c0): {(
     <Person: 0x600000231480>,
     <Person: 0x600000230e60>,
     <Person: 0x60000022f2e0>
     )}
     2018-08-11 17:19:13.431036+0800 TestCocoaPods[1957:105457] copySet(__NSSetI<0x7ffee8bc1b58>: 0x6000002513d0): {(
     <Person: 0x600000231480>,
     <Person: 0x600000230e60>,
     <Person: 0x60000022f2e0>
     )}
     2018-08-11 17:19:13.431175+0800 TestCocoaPods[1957:105457] mutableCopySet(__NSSetM<0x7ffee8bc1b50>: 0x600000231820): {(
     <Person: 0x600000231480>,
     <Person: 0x600000230e60>,
     <Person: 0x60000022f2e0>
     )}
     2018-08-11 17:19:13.431305+0800 TestCocoaPods[1957:105457] end
     */
    NSLog(@"end");
}

@end
