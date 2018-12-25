//
//  XDZModuleManager.h
//  XDZRouter
//
//  Created by mac on 2018/9/15.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface XDZModuleManager : NSObject

/**
 *  模块注册方法，把class和protocol注册给管理器
 */
//+ (void)registerModuleClass:(Class)moduleClass protocol:(Protocol)protocol;

/**
 *  通过protocol获取模块实例
 */
+ (id)getModuleWithProtocol:(Protocol *)protocol;

@end
