//
//  RegisterApi.m
//  XDZNetwork
//
//  Created by mac on 2018/12/25.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "RegisterApi.h"

@interface RegisterApi ()
{
    NSString *_username;
    NSString *_password;
}

@end

@implementation RegisterApi

- (instancetype)initWithUserName:(NSString *)username withPassword:(NSString *)password
{
    self = [super init];
    if (self) {
        _username = username;
        _password = password;
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
             @"sessionId":@"1381938230",
             @"id":@"12102910920192",
             @"pushId":@"e7292120129019201920129"
             };
}


@end
