//
//  XDZChainRequest.m
//  XDZNetwork
//
//  Created by mac on 2018/12/25.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "XDZChainRequest.h"
#import "YTKChainRequest.h"

@interface XDZChainRequest () <XDZBaseRequestProtocol>

@property (nonatomic, strong) NSMutableArray<id<XDZBaseRequestProtocol>> *requests;
@property (nonatomic, strong) YTKChainRequest *coreRequest;

@property (nonatomic,assign, getter=isExcuting) BOOL excuting;
@property (nonatomic, assign, getter=isFinished) BOOL finished;

@end

@implementation XDZChainRequest

@synthesize tag = _tag;
@synthesize host = _host;
@synthesize port = _port;
@synthesize scheme = _scheme;
@synthesize delegate = _delegate;
@synthesize interface = _interface;
@synthesize requestMethod = _requestMethod;
@synthesize paramSerializeMethod = _paramSerializeMethod;
@synthesize responseSerializeMethod = _responseSerializeMethod;
@synthesize requestData = _requestData;
@synthesize timeoutInterval = _timeoutInterval;

@dynamic request;
@dynamic response;
@dynamic responseStatusCode;
@dynamic error;

@end
