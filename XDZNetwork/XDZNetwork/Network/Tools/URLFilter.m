//
//  URLFilter.m
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "URLFilter.h"

@implementation URLFilter

+ (BOOL)isVailedUrlWithUrl:(NSString *)url
{
    if (url == nil || [url length] <= 0)
    {
        return false;
    }
    
    NSString *regexStr = @"^([a-zA-Z]+://){0,1}((([a-zA-Z0-9\\-]+\\.)+[a-zA-Z]+)|(([\\d]{1,3}\\.){3}([\\d]{1,3})))(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>()]+)*/?$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:url
                                                        options:0
                                                          range:NSMakeRange(0, [url length])];
    
    return numberOfMatches > 0?true:false;
}

@end
