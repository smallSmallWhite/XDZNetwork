//
//  XDZModuleManager.m
//  XDZRouter
//
//  Created by mac on 2018/9/15.
//  Copyright © 2018 鹏sir. All rights reserved.
//

#import "XDZModuleManager.h"
#import "XDZModuleProtocol.h"

#ifdef DEBUG
@protocol ModuleAProtocol <XDZModuleProtocol>

@end

@protocol ModuleBProtocol <XDZModuleProtocol>

@end

@interface ModuleA : NSObject<ModuleAProtocol>

@end

@interface ModuleB : NSObject<ModuleBProtocol>

@end

@implementation ModuleA

- (NSString *)description
{
    return @"ModuleA";
}

@end

@implementation ModuleB

- (NSString *)description
{
    return @"ModuleB";
}

@end
#endif

@interface XDZModuleManager ()

@property (nonatomic, strong) NSMutableDictionary *moduleDict;          // key: Protocol string; value: Class Instance
@property (nonatomic, strong) NSMutableArray<Class> *moduleClassArray;  //存放

@end

@implementation XDZModuleManager

#pragma mark - Life Cycle
+ (instancetype)sharedInstance
{
    static XDZModuleManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self registerModuleAutomaticaly];
    }
    
    return self;
}

#pragma mark - Internal Methods
- (NSMutableDictionary *)moduleDict
{
    if (nil == _moduleDict)
    {
        _moduleDict = [NSMutableDictionary dictionary];
    }
    
    return _moduleDict;
}

- (NSMutableArray *)moduleClassArray
{
    if (nil == _moduleClassArray)
    {
        _moduleClassArray = [NSMutableArray array];
    }
    
    return _moduleClassArray;
}

/**
 *  使用runtime的方式自动注册模块
 */
- (void)registerModuleAutomaticaly
{
    // 测试代码
    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    
    for (unsigned int i = 0; i < count; ++i)
    {
        Class cls = classes[i];
        
        //将遵守XDZModuleProtocol协议的类加入到集合中
        if (class_conformsToProtocol(cls, @protocol(XDZModuleProtocol)))
        {
            [self.moduleClassArray addObject:cls];
        }
    }
    
    if (NULL != classes)
    {
        free(classes);
    }
#ifdef DEBUG
    NSDate *now = [NSDate date];
    NSLog(@"Enum %u classes cost %fs.", count, [[NSDate date] timeIntervalSinceDate:now]);
#endif
}

- (id)getModuleWithProtocol:(Protocol *)protocol
{
    __block id instance = nil;
    
    //判断一个协议是否遵守了另外一个协议
    if (protocol_conformsToProtocol(protocol, @protocol(XDZModuleProtocol)))
    {
        NSString *protocolName = NSStringFromProtocol(protocol);
        instance = [self.moduleDict objectForKey:protocolName];
        
        if (nil == instance)
        {
            [self.moduleClassArray enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                Class cls = obj;
                
                //判断cls是否遵循了protocol协议
                if (class_conformsToProtocol(cls, protocol))
                {
                    instance = [[cls alloc] init];
                    [self.moduleDict setObject:instance forKey:protocolName];
                    *stop = YES;
                }
            }];
        }
    }
    
    return instance;
}

#pragma mark - External Methods
+ (id)getModuleWithProtocol:(Protocol *)protocol
{
    return [[self sharedInstance] getModuleWithProtocol:protocol];
}

@end
