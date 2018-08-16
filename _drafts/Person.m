//
//  Person.m
//  TestCocoaPods
//
//  Created by 张远文 on 2018/8/9.
//  Copyright © 2018年 张远文. All rights reserved.
//

#import "Person.h"

@implementation Person

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"无名";
        _sex = 1;
        _age = 9999;
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    NSLog(@"%@ %s", self, __func__);
    return [[[self class] alloc] init];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSLog(@"%@ %s", self, __func__);
    return [[[self class] alloc] init];
}

- (void)showInfo {
    NSLog(@"\n个人信息：\n名字：%@\n性别：%@\n年龄：%@\n", self.name, @(self.sex), @(self.age));
}

- (void)eat {
    NSLog(@"%@吃饭", self);
}

- (void)drink {
    NSLog(@"%@喝水", self);
}

- (void)privateSex {
    NSLog(@"%@有秘密", self);
}

@end
