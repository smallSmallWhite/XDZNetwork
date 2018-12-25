//
//  GetUserInfoApi.m
//  XDZNetwork
//
//  Created by mac on 2018/12/25.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "GetUserInfoApi.h"

@interface GetUserInfoApi ()
{
    NSString *_code;
}

@end

@implementation GetUserInfoApi

- (instancetype)initWithCode:(NSString *)code
{
    if (self)
    {
        _code = code;
    }
    return self;
}

- (NSString *)requestUrl
{
    return @"http://experimentapp.hdyl.net.cn/xdz/user/userUpdate";
}

- (YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPOST;
}

- (id)requestArgument
{
    return @{
             @"sessionId":_code,
             @"id":@"12102910920192",
             @"pushId":@"e7292120129019201920129"
             };
}

@end
