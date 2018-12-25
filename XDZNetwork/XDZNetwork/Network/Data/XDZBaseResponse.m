//
//  XDZBaseResponse.m
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "XDZBaseResponse.h"

@implementation XDZBaseResponse

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper
{
    return @{@"_id": @"id"};
}

@end
