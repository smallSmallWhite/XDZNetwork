//
//  XDZDefaultResponse.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "XDZBaseResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface XDZDefaultResponse : XDZBaseResponse

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, strong)  id data;

@end

NS_ASSUME_NONNULL_END
