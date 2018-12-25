//
//  XDZNetworkCommonDefines.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

//  包含了一些网络模块的通用定义

// 请求方式
#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, XDZRequestMethod)
{
    XDZRequestMethodUndetermin = -1,  // 仅用于初始化
    XDZRequestMethodPost = 0,
    XDZRequestMethodGet = 1,
    XDZRequestMethodPUT = 2,
    XDZRequestMethodDELETE = 3,
};

typedef NS_ENUM(NSInteger, XDZRequestParamSerializeMethod)
{
    XDZRequestParamSerializeMethodUndetermin = -1,  // 仅用于初始化
    
    // 参数会以x-www-form-urlencoded的方式，放到HTTP body中去，对于GET方法不起效
    XDZRequestParamSerializeMethodHTTP = 0,
    
    // 参数会通过NSJSONSerialization直接转换为data的方式填入HTTP body，对GET方法不起效
    XDZRequestParamSerializeMethodJSON = 1,
};

typedef NS_ENUM(NSInteger, XDZResponseSerializeMethod)
{
    XDZResponseSerializeMethodUndetermin = -1,      // 仅用于初始化，可能不会使用
    
    // 支持任何形式的Response ContentType，回以raw data的方式从response.data中带回
    XDZResponseSerializeMethodHTTP = 0,
    
    // 支持JSON格式和text/javascript格式的content，此时可以通过response.jsonObject访问JSON数据
    XDZResponseSerializeMethodJSON = 1,
    
    // 支持XML格式的返回，会验证返回的raw data是否是合法的xml，如果不是会出错，数据在response.data中
    XDZResponseSerializeMethodXML = 2,
};

// 这两个宏定义为方便demo搭建，稍后删除
#define HRZNetworkLocalError  -9999
#define HRZNetworkLocalErrorDomain  @"LocalError"

// Schemes
#define kHttpsScheme  @"https"
#define kHttpScheme   @"http"

// Parser
#define kIDReplacer  @"_id"

#define kInvalidPort  -1

// 服务器使用这个字符串标示成功
#define kHrzResponseCodeOK  @"00000"

#define iStrValid(f) (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])
#define iSafeStr(f) (StrValid(f) ? f:@"")
#define iHasString(str,key) ([str rangeOfString:key].location!=NSNotFound)

#define isValidStr(f) iStrValid(f)
#define isValidDict(f) (f!=nil && [f isKindOfClass:[NSDictionary class]])
#define isValidArray(f) (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
#define isValidNum(f) (f!=nil && [f isKindOfClass:[NSNumber class]])
#define isValidClass(f,cls) (f!=nil && [f isKindOfClass:[cls class]])
#define isValidData(f) (f!=nil && [f isKindOfClass:[NSData class]])


#ifdef DEBUG
/// 以下为开发调试环境网络接口定义-DEVELOP
#define URL_SERVER_MAIN @"experimentapp.hdyl.net.cn"
#define REQUEST_PATH(api) [NSString stringWithFormat:@"/xdz%@", api]
#define REQUEST_PORT -1
#define REQUEST_SCHEME kHttpScheme
#else

#define URL_SERVER_MAIN @"experimentapp.hdyl.net.cn"
#define REQUEST_PATH(api) [NSString stringWithFormat:@"/xdz%@", api]
#define REQUEST_PORT -1
#define REQUEST_SCHEME kHttpScheme

#endif

