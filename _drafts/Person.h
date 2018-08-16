//
//  Person.h
//  TestCocoaPods
//
//  Created by 张远文 on 2018/8/9.
//  Copyright © 2018年 张远文. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger sex;
@property (nonatomic, assign) NSUInteger age;

- (void)showInfo;

- (void)eat;

- (void)drink;

@end

