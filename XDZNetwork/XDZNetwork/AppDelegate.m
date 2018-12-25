//
//  AppDelegate.m
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "AppDelegate.h"
#import "XDZNetworkService.h"
#import "XDZBaseRequestData.h"
#import "XDZBaseRequest.h"
#import "XDZNetworkCommonDefines.h"
#import "XDZModuleManager.h"
#import "XDZBatchRequest.h"
#import "XDZDefaultResponse.h"
#import "XDZGTBinding.h"

@interface AppDelegate () <XDZNetworkResponseDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
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
    
    return YES;
}

- (void)onNetworkRequest:(id<XDZBaseRequestProtocol>)request didFailWithError:(NSError *)error
{
    
    
}

- (void)onNetworkRequest:(id<XDZBaseRequestProtocol>)request didSuccessWithResponseData:(__kindof XDZBaseResponse *)responseData
{
    
    
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
