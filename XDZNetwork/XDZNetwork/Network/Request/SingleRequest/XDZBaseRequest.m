//
//  XDZBaseRequest.m
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "XDZBaseRequest.h"
#import "XDZBaseRequest+YTKAdaption.h"
#import "XDZYTKBaseRequest.h"
#import "XDZBaseResponse.h"

#import "NSObject+YYModel.h"
#import "YTKBatchRequest.h"

@interface XDZBaseRequest () <YTKRequestDelegate>

// 这个成员在YTKAdaption分类中暴露，如果修改名字，请同时修改两处
@property (nonatomic, strong) XDZYTKBaseRequest *coreRequest;

// Important to inspect the response
@property (nonatomic, assign) Class responseDataType;

// 为了保证能通过kvo方式观察状态，重写状态的读写属性
@property (nonatomic,assign, getter=isExcuting) BOOL excuting;
@property (nonatomic, assign, getter=isFinished) BOOL finished;

@end


@implementation XDZBaseRequest

@synthesize tag = _tag;
@synthesize host = _host;
@synthesize port = _port;
@synthesize scheme = _scheme;
@synthesize delegate = _delegate;
@synthesize interface = _interface;
@synthesize requestMethod = _requestMethod;
@synthesize paramSerializeMethod = _paramSerializeMethod;
@synthesize responseSerializeMethod = _responseSerializeMethod;
@synthesize requestData = _requestData;

// These dynamic properties depends on coreRequest type, take care of it
@dynamic error;
@dynamic request;
@dynamic cancelled;
@dynamic response;
@dynamic timeoutInterval;
@dynamic responseStatusCode;

#pragma mark -
#pragma mark Life Circle
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _port = REQUEST_PORT;
        _host = URL_SERVER_MAIN;
        _scheme = REQUEST_SCHEME;
        
        _requestMethod = XDZRequestMethodGet;
        _paramSerializeMethod = XDZRequestParamSerializeMethodJSON;
        _responseSerializeMethod = XDZResponseSerializeMethodJSON;
        
        // 初始化底层的网络请求
        self.coreRequest = [[XDZYTKBaseRequest alloc] init];
        
        _coreRequest.delegate = self;
        _coreRequest.requestMethod = _requestMethod;
        _coreRequest.requestTimeoutInterval = 60.f;
        
        [_coreRequest setRequestParamSerializeMethod:_paramSerializeMethod];
        [_coreRequest setResponseSerializeMethod:_responseSerializeMethod];
        [_coreRequest addAccessory:self];
    }
    
    return self;
}

- (instancetype)initWithResponseDataType:(Class)responseDataType
{
    self = [self init];
    
    if (self)
    {
        if ([responseDataType isSubclassOfClass:[XDZBaseResponse class]])
        {
            self.responseDataType = responseDataType;
        }
    }
    
    return self;
}

- (void)dealloc
{
    _coreRequest.delegate = nil;
    self.delegate = nil;
}

#pragma mark -
#pragma mark Customize
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    [_coreRequest setRequestTimeoutInterval:timeoutInterval];
}

- (NSTimeInterval)timeoutInterval
{
    return [_coreRequest requestTimeoutInterval];
}

- (void)setRequestMethod:(XDZRequestMethod)requestMethod
{
    if (_requestMethod != requestMethod)
    {
        // coreRequest 内部会将method转换为YTK专用的枚举，故需要本身保留一份
        _requestMethod = requestMethod;
        [_coreRequest setRequestMethod:requestMethod];
    }
}

- (void)setParamSerializeMethod:(XDZRequestParamSerializeMethod)paramSerializeMethod
{
    if (_paramSerializeMethod != paramSerializeMethod)
    {
        _paramSerializeMethod = paramSerializeMethod;
        [_coreRequest setRequestParamSerializeMethod:paramSerializeMethod];
    }
}

- (void)setResponseSerializeMethod:(XDZResponseSerializeMethod)responseSerializeMethod
{
    if (_responseSerializeMethod != responseSerializeMethod)
    {
        _responseSerializeMethod = responseSerializeMethod;
        [_coreRequest setResponseSerializeMethod:responseSerializeMethod];
    }
}

- (void)setHost:(NSString *)host
{
    if (_host != host)
    {
        _host = host;
        [self determinUrlForCoreRequest];  // 检查是否可以为底层请求构建完整的URL地址
    }
}

- (void)setInterface:(NSString *)interface
{
    if (_interface != interface)
    {
        _interface = interface;
        NSAssert(isValidStr(_interface), @"%s: Nil url path result in no-op", __PRETTY_FUNCTION__);
        
        [self determinUrlForCoreRequest];
    }
}

- (void)setScheme:(NSString *)scheme
{
    if (_scheme != scheme)
    {
        _scheme = scheme;
        [self determinUrlForCoreRequest];
    }
}

- (void)setPort:(NSInteger)port
{
    if (_port != port)
    {
        _port = port;
        [self determinUrlForCoreRequest];
    }
}

- (void)setValueFor:(NSString * _Nullable)value forHeaderField:(NSString *)headerField
{
    [_coreRequest setValue:value forHTTPHeaderField:headerField];
}

- (void)setRequestData:(id<XDZBaseRequestDataProtocol>)requestData
{
    if (_requestData != requestData)
    {
        if ([requestData conformsToProtocol:@protocol(XDZBaseRequestDataProtocol)] || _requestData == nil)
        {
            // 设置参数
            _requestData = requestData;
            [_coreRequest setRequestParams:[self.requestData requestParams]];
        }
    }
}

#pragma mark -
#pragma mark Introspection
- (NSURLRequest *)request
{
    return _coreRequest.currentRequest;
}

- (NSHTTPURLResponse *)response
{
    return _coreRequest.response;
}

- (NSInteger)responseStatusCode
{
    return _coreRequest.responseStatusCode;
}

- (NSError *)error
{
    return _coreRequest.error;
}

#pragma mark -
#pragma mark Process
- (void)setExcuting:(BOOL)excuting
{
    if (_excuting != excuting)
    {
        [self willChangeValueForKey:@"excuting"];
        _excuting = excuting;
        [self didChangeValueForKey:@"excuting"];
    }
}

- (BOOL)isCancelled
{
    return _coreRequest.cancelled;
}

- (void)setFinished:(BOOL)finished
{
    if (_finished != finished)
    {
        [self willChangeValueForKey:@"finished"];
        _finished = finished;
        [self didChangeValueForKey:@"finished"];
    }
}

#pragma mark -
#pragma mark Private Methods
- (void)determinUrlForCoreRequest
{
    if (!isValidStr(_scheme) || !isValidStr(_host) || !isValidStr(_interface))
    {
        return;
    }
    
    // 设置path时，需要保证path是以/开头的
    if (![_interface hasPrefix:@"/"])
    {
        _interface = [@"/" stringByAppendingString:_interface];
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = _scheme;
    components.host = _host;
    components.path = _interface;
    
    if (_port != kInvalidPort)
    {
        components.port = @(_port);
    }
    
    [_coreRequest setRequestUrl:[components URL]];
}

- (void)handleNetworkRequestFinished:(__kindof YTKBaseRequest *)request
{
    NSError *error = nil;
    NSDictionary *responseJson = nil;  // 返回数据的JSON格式
    
    do
    {
        if (request.responseJSONObject == nil && request.responseData == nil)
        {
            // 这种情况下无法还原数据，属于数据异常的场景，请开发人员检查数据
            assert(false);
            error = [NSError errorWithDomain:HRZNetworkLocalErrorDomain code:HRZNetworkLocalError userInfo:@{NSLocalizedDescriptionKey: @"Success with empty response"}];
            break;
        }
        
        if (!isValidDict(request.responseJSONObject))
        {
            // 如果给出的JSONObject不是字典类型，尝试serialize responseData
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableLeaves error:&error];
            
            if (!isValidDict( jsonObject))
            {
                // 这种情况同样属于数据异常，请开发人员检查接口及数据
                assert(false);
                break;
            }
            
            responseJson = jsonObject;
        }
        else
        {
            responseJson = request.responseJSONObject;
        }
        
    } while (NO);
    
    if (error != nil)
    {
        [self notifyDelegateFailedOnMainThreadWithError:error];
        return;
    }
    
    XDZBaseResponse  *responseData = [self deserializeResponseDataWithJsonObject:responseJson];
    if (responseData == nil)
    {
        assert(false);
        [self notifyDelegateFailedOnMainThreadWithError:nil];
    }
    else
    {
        [self notifyDelegateSuccessOnMainThreadWithData:responseData];
    }
}

- (__kindof XDZBaseResponse *)deserializeResponseDataWithJsonObject:(NSDictionary *)responseJson
{
    XDZBaseResponse *result = nil;
    
    do
    {
        if (!isValidDict(responseJson))
        {
            break;
        }
        
        if (![_responseDataType isSubclassOfClass:[XDZBaseResponse class]])
        {
            // 保险判断
            NSAssert(false, @"%s: Unexpected response data type: %@", __PRETTY_FUNCTION__, _responseDataType);
            break;
        }
        
        // 还原为指定类型的数据
        
        XDZBaseResponse *data = [_responseDataType yy_modelWithDictionary:responseJson];
        if (![data isKindOfClass:[XDZBaseResponse class]])
        {
            // 命中这个断言请检查对应Request的构造函数
            NSAssert(false, @"%s: Can't import data into model: %@", __PRETTY_FUNCTION__,  _responseDataType);
            break;
        }
        
        result = data;
        
    } while (NO);
    
    return result;
}

- (void)withdrawFromCoreRequestAccessory
{
    [_coreRequest.requestAccessories removeObject:self];
}

#pragma mark -
#pragma mark Notify Delegate
- (void)notifyDelegateFailedWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(onNetworkRequest:didFailWithError:)])
    {
        [self.delegate onNetworkRequest:self didFailWithError:error];
    }
}

- (void)notifyDelegateSuccessWithData:(__kindof XDZBaseResponse *)responseData
{
    if ([self.delegate respondsToSelector:@selector(onNetworkRequest:didSuccessWithResponseData:)])
    {
        [self.delegate onNetworkRequest:self didSuccessWithResponseData:responseData];
    }
}

- (void)notifyDelegateFailedOnMainThreadWithError:(NSError *)error
{
    if (![NSThread mainThread])
    {
        [self performSelectorOnMainThread:@selector(notifyDelegateFailedWithError:) withObject:error waitUntilDone:NO];
    }
    else
    {
        [self notifyDelegateFailedWithError:error];
    }
}

- (void)notifyDelegateSuccessOnMainThreadWithData:(__kindof XDZBaseResponse *)responseData
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(notifyDelegateSuccessWithData:) withObject:responseData waitUntilDone:NO];
    }
    else
    {
        [self notifyDelegateSuccessWithData:responseData];
    }
}

#pragma mark -
#pragma mark YTKRequest Delegate
- (void)requestFinished:(__kindof YTKBaseRequest *)request
{
    if (_responseDataType != nil)
    {
        [self handleNetworkRequestFinished:request];
    }
    
    // 目前没有更好的时机，如果在stop的accessory接口中做该操作，会导致
    // 在mutableArray遍历的过程中移除属性的局面
    [self setExcuting:NO];
    [self setFinished:YES];
    [self withdrawFromCoreRequestAccessory];   // Remove, or memery leak
}

- (void)requestFailed:(__kindof YTKBaseRequest *)request
{
    [self notifyDelegateFailedOnMainThreadWithError:request.error];
    
    // 目前没有更好的时机，如果在stop的accessory接口中做该操作，会导致
    // 在mutableArray遍历的过程中移除属性的局面
    [self setExcuting:NO];
    [self setFinished:YES];
    [self withdrawFromCoreRequestAccessory];     // Remove, or memery leak
}

#pragma mark -
#pragma mark YTKRequest Accessory
- (void)requestWillStart:(id)request
{
    self.excuting = YES;
    self.finished = NO;
}

- (void)requestWillStop:(id)request
{
    // 只有在willStop中提前调用HRBaseRequest的delegate才能保证最后一个完成请求委托能正常执行
    // 因为内部请求会先通过委托告知YTKBatchRequest请求完成，再调用didStop的accessory，因此最后一个
    // 请求想通过accessory通知外层的话，一定不能在didStop的accessory中实现该逻辑
    
    if (request != self.coreRequest)
    {
        // 正常情况不会命中
        assert(false);
        return;
    }
    
    // 实际的类型是HRZYTKBaseRequest，但此处使用其基类即可
    YTKBaseRequest *baseRequest = (YTKBaseRequest *)request;
    
    // 基于YTKBatchRequest会强制修改内部delegate的情况，这里做了一个非常不好的、无奈的判断，目的是区分该
    // 请求的委托是否被BatchRequest吃掉了，转而通过accessory的方式通知上层业务一个请求结束，这样才能保证
    // BatchRequest中的每个网络请求结束都能得到及时处理，以减少等待时间。
    if ([baseRequest.delegate isKindOfClass:[YTKBatchRequest class]])
    {
        // 重置了request的委托，这时候需要在该方法处通知外层
        if (baseRequest.responseStatusCode >= 200 && baseRequest.responseStatusCode < 300 && baseRequest.responseObject != nil)
        {
            [self handleNetworkRequestFinished:baseRequest];
        }
        else
        {
            [self notifyDelegateFailedOnMainThreadWithError:baseRequest.error];
        }
        
        // 这里不要移除accessory，这样做会到导致收不到didStop的accessory回调
    }
}

- (void)requestDidStop:(id)request
{
    if (request != self.coreRequest)
    {
        assert(false);
        return;
    }
    
    self.excuting = NO;
    self.finished = YES;
    
    // 要注意这里移除accessory的时机，如果在同一runloop中执行会导致在mutable array遍历时增删该数组的问题
    // 因此推迟到下一个runloop去完成, 该request会推迟到下个runloop销毁。请code reviewer帮忙检查
    [self performSelectorOnMainThread:@selector(withdrawFromCoreRequestAccessory) withObject:nil waitUntilDone:NO];
}

@end
