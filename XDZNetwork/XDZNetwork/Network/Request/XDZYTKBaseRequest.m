//
//  XDZYTKBaseRequest.m
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//  该类继承自猿题库的基础请求类，目标在于适配YTKBaseRequest需要
//  继承才能修改的属性。如若业务变更需要替换底层网络驱动，删除该类
//  即可，不影响享多赚本身的网络层封装

#import "XDZYTKBaseRequest.h"
#import "UrlFilter.h"

@interface XDZYTKBaseRequest ()

@property (nonatomic, copy) NSString *interface;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, assign) YTKRequestMethod innerRequestMethod;
@property (nonatomic, assign) YTKRequestSerializerType innerRequestSerializerType;
@property (nonatomic, assign) YTKResponseSerializerType innerResponseSerializerType;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *customHeaderFields;

@end

@implementation XDZYTKBaseRequest

- (void)dealloc
{
    self.params = nil;
    self.interface = nil;
    self.url = nil;
    self.customHeaderFields = nil;
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)headerField
{
    if (!isValidStr(headerField))
    {
        NSAssert1(false, @"%s, Non-nil header field is required", __PRETTY_FUNCTION__);
    }
    
    if (isValidStr(value) && _customHeaderFields[headerField] != nil)
    {
        // 空value会从header字典中删除这个字段
        [_customHeaderFields removeObjectForKey:headerField];
    }
    
    // 如果有需要则创建字段容器
    if (!isValidDict(_customHeaderFields))
    {
        self.customHeaderFields = [NSMutableDictionary dictionary];
    }
    [_customHeaderFields setValue:value forKey:headerField];
}

- (void)setRequestUrl:(NSURL *)url
{
    NSString *requestUrl = [url absoluteString];
    
    if (![URLFilter isVailedUrlWithUrl:requestUrl])
    {
        NSAssert(false, @"%s, This is not suppose to happend : %@", __PRETTY_FUNCTION__, url);
        return;
    }
    
    // YTKNetAgent需要区分baseUrl和requestUrl
    self.interface = [url path];
    self.url = requestUrl;
}

- (void)setRequestParams:(NSDictionary *)requestParams
{
    self.params = requestParams;
}

- (void)setRequestMethod:(XDZRequestMethod)requestMethod
{
    YTKRequestMethod innerMethod = YTKRequestMethodGET;
    
    switch (requestMethod) {
        case XDZRequestMethodGet:
            break;
            
        case XDZRequestMethodPost:
            innerMethod = YTKRequestMethodPOST;
            break;
        case XDZRequestMethodPUT:
            innerMethod = YTKRequestMethodPUT;
            break;
        case XDZRequestMethodDELETE:
            innerMethod = YTKRequestMethodDELETE;
            break;
            
        default:
            NSAssert(false, @"Undefined HRZRequestMethod: %zd", requestMethod);
            break;
    }
    
    self.innerRequestMethod = innerMethod;
}

- (void)setRequestParamSerializeMethod:(XDZRequestParamSerializeMethod)serializeMethod
{
    YTKRequestSerializerType innerMethod = YTKRequestSerializerTypeHTTP;
    
    switch (serializeMethod) {
        case XDZRequestParamSerializeMethodHTTP:
            [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            break;
            
        case XDZRequestParamSerializeMethodJSON:
            innerMethod = YTKRequestSerializerTypeJSON;
            [self setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
            
        default:
            NSAssert(false, @"Undefined HRZParamSerializeMethod: %zd", serializeMethod);
            break;
    }
    
    self.innerRequestSerializerType = innerMethod;
}

- (void)setResponseSerializeMethod:(XDZResponseSerializeMethod)serializeMethod
{
    YTKResponseSerializerType innerMethod = YTKResponseSerializerTypeJSON;
    
    switch (serializeMethod) {
        case XDZResponseSerializeMethodJSON:
            break;
            
        case XDZResponseSerializeMethodXML:
            innerMethod = YTKResponseSerializerTypeXMLParser;
            break;
            
        case XDZResponseSerializeMethodHTTP:
            innerMethod = YTKResponseSerializerTypeHTTP;
            break;
            
        default:
            NSAssert(false, @"Undefined HRZResponseSerializeMethod: %zd", serializeMethod);
            break;
    }
    
    self.innerResponseSerializerType = innerMethod;
}

- (void)setRequestTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    self.timeout = timeoutInterval;
}

#pragma mark -
#pragma mark Override Functions
- (NSString *)requestUrl
{
    return _interface;
}

- (NSString *)baseUrl
{
    return _url;
}

- (NSDictionary *)requestArgument
{
    return _params;
}

- (YTKRequestMethod)requestMethod
{
    return _innerRequestMethod;
}

- (YTKRequestSerializerType)requestSerializerType
{
    return _innerRequestSerializerType;
}

- (NSTimeInterval)requestTimeoutInterval
{
    return _timeout;
}

- (YTKResponseSerializerType)responseSerializerType
{
    return _innerResponseSerializerType;
}

- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary
{
    return _customHeaderFields;
}

- (BOOL)statusCodeValidator
{
    if ([super statusCodeValidator])
    {
        return YES;
    }
    
    // 在测试时发现存在请求成功但NSURLSessionTask的response为空的问题，导致原框架的状态码校验直接出错(状态码此时为0)
    // 此时判断一下是否属于这种情况，如果是，则通过验证回复数据本身来解决问题
    if (self.response == nil && (self.responseString.length != 0 || self.responseData.length != 0))
    {
        return YES;
    }
    
    return NO;
}




@end
