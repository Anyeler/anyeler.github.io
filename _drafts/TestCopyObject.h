//
//  TestCopyObject.h
//  TestCocoaPods
//
//  Created by 张远文 on 2018/8/9.
//  Copyright © 2018年 张远文. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestCopyObject : NSObject

#pragma mark - String
+ (void)stringCopy;

+ (void)mutableStringCopy;

#pragma mark - Array
+ (void)arrayCopy;

+ (void)mutableArrayCopy;

#pragma mark - Dictionary
+ (void)dictionaryCopy;

+ (void)mutableDictionaryCopy;

#pragma mark - Set
+ (void)setCopy;

+ (void)mutableSetCopy;

@end
