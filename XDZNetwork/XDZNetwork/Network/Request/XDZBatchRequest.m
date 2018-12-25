//
//  XDZBatchRequest.m
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "XDZBatchRequest.h"
#import "XDZBatchRequest+ServicePrivate.h"
#import "XDZBaseRequest+YTKAdaption.h"

#import "YTKBatchRequest.h"
#import "YTKRequest.h"

@interface XDZBatchRequest () <YTKBatchRequestDelegate>

@property (nonatomic, strong) NSMutableArray<id<XDZBaseRequestProtocol>> *requests;
@property (nonatomic, strong) YTKBatchRequest *coreRequest;

@property (nonatomic,assign, getter=isExcuting) BOOL excuting;
@property (nonatomic, assign, getter=isFinished) BOOL finished;

@end

@implementation XDZBatchRequest

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
@synthesize timeoutInterval = _timeoutInterval;

@dynamic request;
@dynamic response;
@dynamic responseStatusCode;
@dynamic error;

- (instancetype)initWithResponseDataType:(Class)responseDataType
{
    NSAssert(false, @"This function should never be called: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (instancetype)initWithBaseRequests:(NSArray<id<XDZBaseRequestProtocol>> *)requests
{
    self = [super init];
    if (self)
    {
        if (![self initializeInnerModelWithRequest:requests])
        {
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_coreRequest stop];
}

#pragma mark -
#pragma mark Private Category
- (void)start
{
    [_coreRequest start];
}

- (void)stop
{
    [_coreRequest stop];
}

#pragma mark -
#pragma mark Customize
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    if (timeoutInterval != _timeoutInterval)
    {
        _timeoutInterval = timeoutInterval;
    }
    
    [_requests enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        request.timeoutInterval = timeoutInterval;
    }];
}

- (void)setRequestMethod:(XDZRequestMethod)requestMethod
{
    if (requestMethod != _requestMethod)
    {
        _requestMethod = requestMethod;
    }
    
    [_requests enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        request.requestMethod = requestMethod;
    }];
}

- (void)setParamSerializeMethod:(XDZRequestParamSerializeMethod)paramSerializeMethod
{
    if (paramSerializeMethod != _paramSerializeMethod)
    {
        _paramSerializeMethod = paramSerializeMethod;
    }
    
    [_requests enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        request.paramSerializeMethod = paramSerializeMethod;
    }];
}

- (void)setResponseSerializeMethod:(XDZResponseSerializeMethod)responseSerializeMethod
{
    if (responseSerializeMethod != _responseSerializeMethod)
    {
        _responseSerializeMethod = responseSerializeMethod;
    }
    
    [_requests enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        request.responseSerializeMethod = responseSerializeMethod;
    }];
}

- (void)setHost:(NSString *)host
{
    if (host != _host)
    {
        _host = host;
    }
    
    [_requests enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        request.host = host;
    }];
}

- (void)setScheme:(NSString *)scheme
{
    if (scheme != _scheme)
    {
        _scheme = scheme;
    }
    
    [_requests enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        request.scheme = scheme;
    }];
}

- (void)setPort:(NSInteger)port
{
    if (port != _port)
    {
        _port = port;
    }
    
    [_requests enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        request.port = port;
    }];
}

- (void)setValueFor:(NSString * _Nullable)value forHeaderField:(nonnull NSString *)headerField
{
    [_requests enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        [request setValueFor:value forHeaderField:headerField];
    }];
}

- (void)setDelegate:(id<XDZNetworkResponseDelegate>)delegate
{
    if (delegate != _delegate)
    {
        _delegate = delegate;
    }
    
    [_requests enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        if (request.delegate == nil)
        {
            request.delegate = delegate;
        }
    }];
}

#pragma mark -
#pragma mark Introspection
- (NSURLRequest *)request
{
    return nil;
}

- (NSHTTPURLResponse *)response
{
    return nil;
}

- (NSInteger)responseStatusCode
{
    return -1;
}

- (NSError *)error
{
    return nil;
}

#pragma mark -
#pragma mark Process
- (BOOL)isCancelled
{
    // 对于batchRequest的cancel状态，目前无法判断
    return NO;
}

- (void)setExcuting:(BOOL)excuting
{
    if (_excuting != excuting)
    {
        [self willChangeValueForKey:@"excuting"];
        _excuting = excuting;
        [self didChangeValueForKey:@"excuting"];
    }
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
#pragma mark Collect Requests
- (BOOL)initializeInnerModelWithRequest:(NSArray<id<XDZBaseRequestProtocol>> *)requests
{
    if (requests.count == 0)
    {
        return NO;
    }
    
    self.requests = [NSMutableArray arrayWithArray:requests];
    
    // 将请求放入YTKBatchRequest中
    NSArray<YTKRequest *> *ytkRequests = [self prepare3rdPartyRequests:requests];
    if (ytkRequests.count == 0)
    {
        return NO;
    }
    
    self.coreRequest = [[YTKBatchRequest alloc] initWithRequestArray:ytkRequests];
    self.coreRequest.delegate = self;
    
    return YES;
}

- (NSArray *)prepare3rdPartyRequests:(NSArray<id<XDZBaseRequestProtocol>> *)requests
{
    NSMutableArray<YTKRequest *> *ytkRequests = [NSMutableArray array];
    
    [requests enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XDZBaseRequest *baseRequest = (XDZBaseRequest *)obj;
        if (![baseRequest isKindOfClass:[XDZBaseRequest class]])
        {
            return;
        }
        
        YTKRequest *ytkRequest = baseRequest.coreRequest;
        if ([ytkRequest isKindOfClass:[YTKRequest class]])
        {
            [ytkRequests addObject:ytkRequest];
        }
    }];
    
    return ytkRequests;
}

#pragma mark -
#pragma mark YTKRequest Delegate
- (void)batchRequestFinished:(YTKBatchRequest *)batchRequest
{
    // 保留这个断言，观察是否有非主线程的情况
    NSAssert([NSThread isMainThread], @"With this assertion triggered, you should implement a invoke-on-main-thread method");
    
    if ([self.delegate respondsToSelector:@selector(onNetworkRequest:didSuccessWithResponseData:)])
    {
        [self.delegate onNetworkRequest:self didSuccessWithResponseData:nil];
    }
    
    self.excuting = NO;
    self.finished = YES;
    self.requests = nil;
}

- (void)batchRequestFailed:(YTKBatchRequest *)batchRequest
{
    NSAssert([NSThread isMainThread], @"With this assertion triggered, you should implement a invoke-on-main-thread method");
    
    if ([self.delegate respondsToSelector:@selector(onNetworkRequest:didFailWithError:)])
    {
        [self.delegate onNetworkRequest:self didFailWithError:nil];
    }
    
    self.excuting = NO;
    self.finished = YES;
    self.requests = nil;
}

@end
