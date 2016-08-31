//
//  CodeSnippet.m
//  ExtensionsForSafari
//
//  Created by Tian on 16/8/31.
//  Copyright © 2016年 JerryTian. All rights reserved.
//

#import "CodeSnippet.h"

@implementation CodeSnippet

+ (NSString *)primaryKey {
    return @"ID";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{@"code" : @"//write your code on here\\n"};
}

@end
