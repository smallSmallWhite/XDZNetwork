//
//  XDZBaseRequestProtocol.h
//  XDZNetwork
//
//  Created by mac on 2018/12/24.
//  Copyright © 2018 鹏sir. All rights reserved.
//
//  定义了享多赚请求的原型，主要提供基本的网络请求接口

#import <Foundation/Foundation.h>
#import "XDZNetworkCommonDefines.h"
#import "XDZBaseResponse.h"
#import "XDZBaseRequestDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XDZBaseRequestProtocol;

// 定义的请求返回的基本处理接口
@protocol XDZNetworkResponseDelegate <NSObject>

@optional
/**
 * 成功收到的返回的处理接口
 *
 * @param request  请求对象本身
 * @param responseData 请求指定数据类型的解释结果，请注意和reqeust.response区分
 *
 * @discuss 如果需要直接获取raw response，可通过request来获取。
 */
- (void)onNetworkRequest:(id<XDZBaseRequestProtocol>)request didSuccessWithResponseData:(__kindof XDZBaseResponse * _Nullable)responseData;

/**
 * 请求失败的处理接口
 *
 * @param request 请求对象本身
 * @param error 请求出错的描述
 *
 * @discuss error以后可能会定义一些因传参或其他原因导致的本地错误
 */
- (void)onNetworkRequest:(id<XDZBaseRequestProtocol>)request didFailWithError:(NSError * _Nullable)error;

@end

@protocol XDZBaseRequestProtocol <NSObject>

@property (nonatomic, weak, nullable) id<XDZNetworkResponseDelegate> delegate;

#pragma mark -
#pragma mark Customize
// 可以作为一个indentifier
@property (nonatomic, copy) NSString *tag;

// 请求超时时长
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

// 请求方式
@property (nonatomic, assign) XDZRequestMethod requestMethod;

// 参数的转换方式，默认为JSON方式
@property (nonatomic, assign) XDZRequestParamSerializeMethod paramSerializeMethod;

// 返回数据的解释方式， 默认为JSON方式
@property (nonatomic, assign) XDZResponseSerializeMethod responseSerializeMethod;

// 请求的Host，如果将host设置为空，网络层会使用默认server
@property (nonatomic, copy, nullable) NSString *host;

// 请求的scheme，如果设置为空，网络层默认使用https
@property (nonatomic, copy, nullable) NSString *scheme;

// 请求的接口
@property (nonatomic, copy) NSString *interface;

// 请求端口号
@property (nonatomic, assign) NSInteger port;

// requestData 请求参数，对与一些直接GET接口数据不需要参数的请求，可以不设置
@property (nonatomic, strong) id<XDZBaseRequestDataProtocol> requestData;

#pragma mark -
#pragma mark Introspection
// 实际使用的网络请求
@property (nonatomic, strong, readonly, nullable) NSURLRequest *request;

// 请求对应的返回
@property (nonatomic, strong, readonly, nullable) NSHTTPURLResponse *response;

// 返回的状态码，shortcut for response.statusCode
@property (nonatomic, assign, readonly) NSInteger responseStatusCode;

// 请求的错误描述
@property (nonatomic, strong, readonly, nullable) NSError *error;

#pragma mark -
#pragma mark Process
// 是否正在执行
@property (nonatomic,assign, readonly, getter=isExcuting) BOOL excuting;

// 是否被cancel
// PS：出于技术原因，目前cancelled属性无法进行KVO
@property (nonatomic, assign, readonly, getter=isCancelled) BOOL cancelled;

// 是否结束，如果要判断结束原因，进一步判断cancel
@property (nonatomic, assign, readonly, getter=isFinished) BOOL finished;

#pragma mark -
#pragma mark Methods
/**
 * Designated initializer
 *
 * @param responseDataType 是请求对应的返回数据类型，用于网络层在收到回复数据后恰当地解释JSON数据
 */
- (instancetype)initWithResponseDataType:(Class _Nullable)responseDataType;

/**
 * 设置请求的头部内容
 *
 * @param value 头部字段对应的值
 * @param headerField 修改的头部字段
 */
- (void)setValueFor:(NSString * _Nullable)value forHeaderField:(NSString *)headerField;

@end

NS_ASSUME_NONNULL_END
