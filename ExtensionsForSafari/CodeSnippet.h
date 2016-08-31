//
//  CodeSnippet.h
//  ExtensionsForSafari
//
//  Created by Tian on 16/8/31.
//  Copyright © 2016年 JerryTian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface CodeSnippet : RLMObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *code;

@end
