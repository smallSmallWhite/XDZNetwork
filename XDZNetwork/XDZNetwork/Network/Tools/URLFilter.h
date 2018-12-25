//
//  URLFilter.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface URLFilter : NSObject

+ (BOOL)isVailedUrlWithUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
