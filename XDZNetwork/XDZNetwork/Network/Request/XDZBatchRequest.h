//
//  XDZBatchRequest.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//
//  该类为满足广(liang)大(ge)程序员要求实现享多赚对应BatchRequst的请求。该请求遵循HRZBaseRequstProtocol
//  但因为聚焦的功能完全不同，每个接口的实际逻辑跟BaseRequest可能有巨大的差异，请使用者注意：
//
//  1. 该类无法通过- (instancetype)initWithResponseDataType:(Class _Nullable)responseDataType 初始化。因为该类本身无任何网络相关的操作
//
//  2. 该类对所有 Introspection 分类的接口，均返回无意义的值，如nil， -1
//
//  3. 对于Customize分类的接口：
//  3.1 setInterface 和 setRequestData 无任何实际意义，该类不保存任何interface和requsetData
//  3.2 其他接口除setTag外，都作用于该batch 请求关联的base 请求中，如setHost会统一将所有内部base 请求的host改变
//  3.3 tag保留原有意义，但不会影响内部base 请求对应tag的值
//
//  4. delegate，在设置batch 请求的委托时，会检查内部请求的委托是否被设置，对于delegate为nil的请求，会使用batch请求的委托对其赋值
//
//  5. excuting、cancel和finished保持原来的意义和效果
//
//  6. setValueForHeaderField 会统一处理内部所有的请求的header，对已经存在的头不字段会进行复写
//
//  7. 该类不提供访问coreRequst到私有方法。
//
//  8. 出于底层封装的原因，batch中任意一个请求出错，则余下的请求会被终止，并且整个batchRequest会马上执行错误回调

#import <Foundation/Foundation.h>
#import "XDZBaseRequestProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XDZBatchRequest : NSObject <XDZBaseRequestProtocol>

/**
 * 本类专有的构造函数
 *
 * @param requests 关联请求的队列，队列中所有请求完成后，本request的委托才会调用
 */
- (instancetype)initWithBaseRequests:(NSArray<id<XDZBaseRequestProtocol>> *)requests;

@end

NS_ASSUME_NONNULL_END
