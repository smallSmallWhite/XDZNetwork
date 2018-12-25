//
//  XDZGTBinding.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XDZNetworkService.h"
#import "XDZBaseRequestData.h"
#import "XDZBaseRequest.h"
#import "XDZNetworkCommonDefines.h"
#import "XDZModuleManager.h"
#import "XDZBatchRequest.h"
#import "XDZDefaultResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface XDZGTBinding : NSObject 

- (void)sendBindingRequestWithGTDeviceID:(NSString *)GTID;

@end

@interface XDZGTBindingRequestData : XDZBaseRequestData
@property (nonatomic, copy) NSString *getuiClientId;
@end



NS_ASSUME_NONNULL_END
