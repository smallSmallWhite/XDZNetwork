//
//  XDZModuleProtocol.h
//  XDZRouter
//
//  Created by mac on 2018/9/15.
//  Copyright © 2018 鹏sir. All rights reserved.
// 红人装各组件接口必须继承的基础接口，统一的组件接口能让模块更高效地被动发现组件，无需组件主动注册

#import <Foundation/Foundation.h>

@protocol XDZModuleProtocol <NSObject>

@optional
/**
 *  使用者在使用完成后调用。功能：
 *  1.方便模块本身选择向管理器要求释放自己，以减少模块内存常驻
 *  2.方便统计
 */
- (void)finishJobByTarget:(id)target;

@end
