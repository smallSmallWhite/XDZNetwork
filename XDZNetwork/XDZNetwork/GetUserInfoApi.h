//
//  GetUserInfoApi.h
//  XDZNetwork
//
//  Created by mac on 2018/12/25.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "YTKBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface GetUserInfoApi : YTKBaseRequest

- (instancetype)initWithCode:(NSString *)code;

@end

NS_ASSUME_NONNULL_END
