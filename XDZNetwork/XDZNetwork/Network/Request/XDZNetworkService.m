//
//  XDZNetworkService.m
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.


#import "XDZNetworkService.h"
#import "XDZBaseRequest+YTKAdaption.h"
#import "XDZBatchRequest.h"
#import "XDZBatchRequest+ServicePrivate.h"

#import "YTKNetworkAgent.h"
#import "YTKBaseRequest.h"


#define kLockService() [_recursiveLock lock];
#define kUnlockService() [_recursiveLock unlock];

@interface XDZNetworkService ()

@property (nonatomic, strong) NSRecursiveLock *recursiveLock;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<XDZBaseRequestProtocol>> *requestMap;

@end

@implementation XDZNetworkService

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.recursiveLock = [[NSRecursiveLock alloc] init];
        self.requestMap = [NSMutableDictionary dictionary];
        
        self.recursiveLock.name = @"NetworkServiceLock";
    }
    
    return self;
}

- (void)dealloc
{
    [self cancelAllNetworkRequest];
    [self.recursiveLock unlock];
    
    self.recursiveLock = nil;
    self.requestMap = nil;
}

#pragma mark -
#pragma mark Add Request
- (BOOL)addNetworkRequest:(id<XDZBaseRequestProtocol>)request
{
    if (request == nil)
    {
        return NO;
    }
    
    // 管理请求
    // PS： 因为底层使用了YTKNetworkAgent，它负责了实际的任务管理工作。但红人装的网络服务必须自行管理自己的请求：
    // 1. 网络服务需要知道目前的请求执行状态以便能执行finishJobByTarget，
    // 2. 假如替换底层网络引擎，管理请求是必要的routine
    if ([request isKindOfClass:[XDZBatchRequest class]])
    {
        // 新增的批量请求
        return [self addBatchRequest:request];
    }
    else if ([request isKindOfClass:[XDZBaseRequest class]])
    {
        // 原有的请求逻辑
        return [self addBaseRquest:request];
    }
    else
    {
        assert(false);
        return NO;
    }
}

- (BOOL)addBatchRequest:(id<XDZBaseRequestProtocol>)request
{
    if (request == nil || ![request isKindOfClass:[XDZBatchRequest class]])
    {
        return NO;
    }

    XDZBatchRequest *batchRequest = (XDZBatchRequest *)request;

    kLockService();
    batchRequest.tag = [self uniqueRequestTag];
    [_requestMap setValue:batchRequest forKey:batchRequest.tag];

    // 因为YTKNetwork隐藏了所有请求流程细节，而红人装的网络层最起码需要知道请求的结束状态，因此通过KVO解决
    [batchRequest addObserver:self forKeyPath:@"finished" options:NSKeyValueObservingOptionNew context:nil];

    // 将批量请求的内部请求交给网络层托管
    [[batchRequest requests] enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        XDZBaseRequest *request = (XDZBaseRequest *)obj;
        if (![request isKindOfClass:[XDZBaseRequest class]])
        {
            NSAssert(false, @"Type error in batch request: %@", request);
            return;
        }

        // 通过accesory方式通知上层业务的request必须保证自己是自己的coreRequest的accessory
        // 当一个batch request包含了一些会被重用的request时，这个判断就十分必要，因为每次请求完成时
        // 被重用的request总是会从自己的coreRequest的accessory中移除
        YTKBaseRequest *ytkRequest = (YTKBaseRequest *)request.coreRequest;
        if (![ytkRequest.requestAccessories containsObject:request])
        {
            [ytkRequest.requestAccessories addObject:request];
        }

        request.tag = [self uniqueRequestTag];
        [self.requestMap setValue:request forKey:request.tag];

        [request addObserver:self forKeyPath:@"finished" options:NSKeyValueObservingOptionNew context:nil];
    }];

    kUnlockService();

    // 这里调用batchRquest的start即可， 不需要逐个启动内部请求
    [batchRequest start];
    return YES;
}

- (BOOL)addBaseRquest:(id<XDZBaseRequestProtocol>)request
{
    if (request == nil || ![request isKindOfClass:[XDZBaseRequest class]])
    {
        return NO;
    }
    
    // 底层使用YTKNetworkAgent，baseRequest专门为接入这个agent提供了私有成员访问入口
    XDZBaseRequest *baseRequest = (XDZBaseRequest *)request;
    if (![baseRequest.coreRequest isKindOfClass:[YTKBaseRequest class]])
    {
        NSAssert(false, @"Currently, we use YTKNetwork");
        return NO;
    }
    
    // 通过accesory方式通知上层业务的request必须保证自己是自己的coreRequest的accessory
    YTKBaseRequest *ytkRequest = (YTKBaseRequest *)baseRequest.coreRequest;
    if (![ytkRequest.requestAccessories containsObject:baseRequest])
    {
        [ytkRequest.requestAccessories addObject:baseRequest];
    }
    
    kLockService();
    request.tag = [self uniqueRequestTag];
    [_requestMap setValue:request forKey:request.tag];
    kUnlockService();
    
    // 因为YTKNetwork隐藏了所有请求流程细节，而红人装的网络层最起码需要知道请求的结束状态，因此通过KVO解决
    [baseRequest addObserver:self forKeyPath:@"finished" options:NSKeyValueObservingOptionNew context:nil];
    
    // 启动底层的YTKNetwork
    [[YTKNetworkAgent sharedAgent] addRequest:baseRequest.coreRequest];
    
    return YES;
}

#pragma mark -
#pragma mark Cancel Request
- (void)cancelNetworRequest:(id<XDZBaseRequestProtocol>)request
{
    if (request == nil)
    {
        return;
    }
    
    if ([request isKindOfClass:[XDZBatchRequest class]])
    {
        [self cancelBatchReqeust:request];
    }
    else if ([request isKindOfClass:[XDZBaseRequest class]])
    {
        [self cancelBaseRequest:request];
    }
    else
    {
        assert(false);
    }
    
    // 检查是否结束本次服务
    [self checkRemainJobs];
}

- (void)cancelNetworkRequestByID:(NSString *)requestID
{
    if (requestID.length == 0)
    {
        return;
    }
    
    kLockService();
    id<XDZBaseRequestProtocol> request = [_requestMap valueForKey:requestID];
    kUnlockService();
    
    if (request != nil)
    {
        [self cancelNetworRequest:request];
    }
}

- (void)cancelAllNetworkRequest
{
    kLockService();
    
    if (_requestMap.count == 0)
    {
        kUnlockService();
        return;
    }
    
    [_requestMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id<XDZBaseRequestProtocol>  _Nonnull obj, BOOL * _Nonnull stop) {
        
        [self tryRemoveKVOForBaseRequest:obj];
        
        if ([obj isKindOfClass:[XDZBatchRequest class]])
        {
            // 对于批量请求，需要单独处理stop，否则不会从底层一个特殊的networkAgent中移除
            XDZBatchRequest *batchRquest = (XDZBatchRequest *)obj;
            [batchRquest stop];
        }
    }];
    
    kUnlockService();
    
    [[YTKNetworkAgent sharedAgent] cancelAllRequests];
    
    // 移除所有的任务
    kLockService();
    [_requestMap removeAllObjects];
    kUnlockService();
    
    // 检查是否结束本次服务
    [self checkRemainJobs];
}

- (void)cancelBatchReqeust:(id<XDZBaseRequestProtocol>)request
{
    XDZBatchRequest *batchRequest = (XDZBatchRequest *)request;
    if (![batchRequest isKindOfClass:[XDZBatchRequest class]])
    {
        return;
    }

    // 底层驱动停止，注意后续不需要从底层NetworkAgent逐个停止内部请求，在stop接口中已经完成了
    [batchRequest stop];

    // 必须同时处理内部关联请求
    [[batchRequest requests] enumerateObjectsUsingBlock:^(id<XDZBaseRequestProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        XDZBaseRequest *request = (XDZBaseRequest *)obj;
        if (![request isKindOfClass:[XDZBaseRequest class]])
        {
            return;
        }

        [self tryRemoveKVOForBaseRequest:request];
        [self removeRequestFromMap:request];
    }];
    
//     从服务层的管理队列移除
    [self tryRemoveKVOForBaseRequest:batchRequest];
    [self removeRequestFromMap:batchRequest];
}

- (void)cancelBaseRequest:(id<XDZBaseRequestProtocol>)request
{
    XDZBaseRequest *baseRequest = (XDZBaseRequest *)request;
    if (![baseRequest.coreRequest isKindOfClass:[YTKBaseRequest class]])
    {
        NSAssert(false, @"Currently, we use YTKNetwork");
        return;
    }
    
    // 从底层移除
    [[YTKNetworkAgent sharedAgent] cancelRequest:baseRequest.coreRequest];
    
    // 尝试停止对该对象的KVO
    [self tryRemoveKVOForBaseRequest:baseRequest];
    
    // 从管理队列中移除
    [self removeRequestFromMap:baseRequest];
}

#pragma mark -
#pragma mark Private Methods
- (void)tryRemoveKVOForBaseRequest:(id<XDZBaseRequestProtocol>)baseRequest
{
    if (baseRequest == nil)
    {
        return;
    }
    
    kLockService();
    if ([_requestMap valueForKey:baseRequest.tag] != baseRequest)
    {
        // 表示已经从管理队列中移除，或被新的请求取代了
        kUnlockService();
        return;
    }
    
    kUnlockService();
    
    // To remove a warnning
    NSObject *requestObject = (NSObject *)baseRequest;
    
    @try
    {
        [requestObject removeObserver:self forKeyPath:@"finished"];
    }
    @catch (NSException *exception)
    {
        // 为保证请求一定被cancel， 请求被反复取消是可预见的合理行为
        // 不做任何处理
        assert(false);
    }
}

- (void)removeRequestFromMap:(id<XDZBaseRequestProtocol>)request
{
    if (request == nil)
    {
        return;
    }
    
    kLockService();
    
    if ([_requestMap valueForKey:request.tag] != request)
    {
        // 批量请求中的独立请求有可能被覆盖，调用者如果不通过批量请求处理而
        // 绕过它去取消它所包含的独立请求就会出现这种情况
        kUnlockService();
        return;
    }
    
    [_requestMap removeObjectForKey:request.tag];
    kUnlockService();
}

- (void)checkRemainJobs
{
    NSInteger taskCount = 0;
    
    kLockService();
    taskCount = _requestMap.count;
    kUnlockService();
    
    if (taskCount == 0)
    {
//       [self finishJobByTarget:self];
    }
}

- (NSString *)uniqueRequestTag
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 100000;
    NSInteger randomFactor = arc4random_uniform(100000);
    
    return [NSString stringWithFormat:@"%ld",(long)(time + randomFactor)];
    
}

#pragma mark -
#pragma mark KVO Observation
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (![keyPath isEqualToString:@"finished"] || ![object conformsToProtocol:@protocol(XDZBaseRequestProtocol)])
    {
        return;
    }
    
    id<XDZBaseRequestProtocol> request = (id<XDZBaseRequestProtocol>)object;
    if (!request.isFinished)
    {
        // 只在完成时移除
        return;
    }
    
    // 完成后结束对该对象的观察
    [self tryRemoveKVOForBaseRequest:request];
    
    // 从队列中移除，因为YTKNetworkAgent内部可以获取请求的结束状态，顾此处不需要管理YTK的网络请求
    [self removeRequestFromMap:request];
    
    // 是否结束工作
    [self checkRemainJobs];
}

@end
