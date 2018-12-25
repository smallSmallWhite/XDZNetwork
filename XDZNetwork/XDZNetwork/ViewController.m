//
//  ViewController.m
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "ViewController.h"
#import "XDZNetworkService.h"
#import "XDZBaseRequestData.h"
#import "XDZBaseRequest.h"
#import "XDZNetworkCommonDefines.h"
#import "XDZModuleManager.h"
#import "XDZBatchRequest.h"
#import "XDZDefaultResponse.h"
#import "XDZGTBinding.h"
#import "XDZGoodsRequest.h"
#import "YTKChainRequest.h"
#import "RegisterApi.h"
#import "GetUserInfoApi.h"

@interface ViewController () <XDZNetworkResponseDelegate,YTKChainRequestDelegate>



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[[XDZGTBinding alloc] init] sendBindingRequestWithGTDeviceID:@"12192120"];
    
//    NSString *url = [@"/merchantProduct/{productId}.htm" stringByReplacingOccurrencesOfString:@"{productId}" withString:@"121212"];
//    XDZGoodsRequest *requestData = [[XDZGoodsRequest alloc] init];
//
//    XDZBaseRequest *request = [[XDZBaseRequest alloc] initWithResponseDataType:[XDZDefaultResponse class]];
//    request.delegate = self;
//    request.interface = url;
//    request.port = -1;
//    request.host = @"experimentapp.hdyl.net.cn";
//    request.scheme = kHttpsScheme;
//    request.requestMethod = XDZRequestMethodPUT;
//    request.paramSerializeMethod = XDZRequestParamSerializeMethodHTTP;
//    request.responseSerializeMethod = XDZRequestParamSerializeMethodHTTP;
//
//    request.requestData = requestData;
//
//    id<XDZNetworkServiceProtocol> networkService = [XDZModuleManager getModuleWithProtocol:@protocol(XDZNetworkServiceProtocol)];
//    if ([networkService respondsToSelector:@selector(addNetworkRequest:)])
//    {
//        [networkService addNetworkRequest:request];
//    }
    
    RegisterApi *reg = [[RegisterApi alloc] initWithUserName:@"1313" withPassword:@"131313"];
    YTKChainRequest *chainReq = [[YTKChainRequest alloc] init];
    [chainReq addRequest:reg callback:^(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:baseRequest.responseData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"----%@",dic);
        
        GetUserInfoApi *api = [[GetUserInfoApi alloc] initWithCode:dic[@"code"]];
        [chainRequest addRequest:api callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:baseRequest.responseData options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"----%@",dic);
            
        }];
        
    }];
    chainReq.delegate = self;
    // start to send request
    [chainReq start];

    
}

- (void)chainRequestFinished:(YTKChainRequest *)chainRequest
{
    
    
    
}

- (void)chainRequestFailed:(YTKChainRequest *)chainRequest failedBaseRequest:(YTKBaseRequest *)request
{
    
    
    
    
}

- (void)onNetworkRequest:(id<XDZBaseRequestProtocol>)request didFailWithError:(NSError *)error
{
    
    
}

- (void)onNetworkRequest:(id<XDZBaseRequestProtocol>)request didSuccessWithResponseData:(__kindof XDZBaseResponse *)responseData
{
    
    
}




@end
