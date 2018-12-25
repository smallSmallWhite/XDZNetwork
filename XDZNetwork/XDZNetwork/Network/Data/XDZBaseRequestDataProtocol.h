//
//  XDZBaseRequestDataProtocol.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XDZBaseRequestDataProtocol <NSObject>

/**
 * 请求参数
 *
 *  @discuss 网络层会根据请求方式决定params的传送方式：
 *  1. GET请求时，params中的键值对会以URL query的方式添加到请求URL的后面，并自动补全“？”
 *  2. POST请求时，如果传值的方式是以XDZRequestParamSerializeMethodHTTP的方式，则
       params会以x-www-form-urlencoded的方式填充到HTTP request body 中
       如果传值的方式是以XDZRequestParamSerializeMethodJSON的方式，则
       params会以NSJSONSerialization直接转换为data的方式填入HTTP body
 */
- (NSDictionary  *_Nullable)requestParams;

@end

NS_ASSUME_NONNULL_END
