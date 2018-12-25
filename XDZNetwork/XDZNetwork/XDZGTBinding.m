//
//  XDZGTBinding.m
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "XDZGTBinding.h"

@interface XDZGTBinding () <XDZNetworkResponseDelegate>

@end

@implementation XDZGTBinding

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)sendBindingRequestWithGTDeviceID:(NSString *)GTID
{
    XDZGTBindingRequestData *requestData = [[XDZGTBindingRequestData alloc] init];
    requestData.getuiClientId = @"撒开手机卡升级款";
    
    id<XDZBaseRequestProtocol> request = [[XDZBaseRequest alloc] initWithResponseDataType:[XDZDefaultResponse class]];
    request.delegate = self;
    request.requestMethod = XDZRequestMethodPost;
    request.interface = REQUEST_PATH(@"/user/userUpdate");
    request.requestData = requestData;
    
    
    id<XDZNetworkServiceProtocol> networkService = [XDZModuleManager getModuleWithProtocol:@protocol(XDZNetworkServiceProtocol)];
    if ([networkService respondsToSelector:@selector(addNetworkRequest:)])
    {
        [networkService addNetworkRequest:request];
    }
}

- (void)onNetworkRequest:(id<XDZBaseRequestProtocol>)request didFailWithError:(NSError *)error
{
    
    
}

- (void)onNetworkRequest:(id<XDZBaseRequestProtocol>)request didSuccessWithResponseData:(__kindof XDZBaseResponse *)responseData
{
    
    
    
}

@end

@implementation XDZGTBindingRequestData

- (NSDictionary *)requestParams
{
    return @{
             @"sessionId":@"1381938230",
             @"id":@"12102910920192",
             @"pushId":@"e7292120129019201920129"
             };
}



@end
