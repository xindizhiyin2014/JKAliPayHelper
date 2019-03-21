//
//  JKAliPayHelper.m
//  JKAliPayHelper
//
//  Created by JackLee on 2019/3/17.
//

#import "JKAliPayHelper.h"
#import <AlipaySDK/AlipaySDK.h>

static inline NSError * JKErrorBuild(NSInteger errorCode, NSString *domain, NSString *errorMsg){
    NSMutableDictionary *useinfo = [NSMutableDictionary dictionary];
    if (errorMsg) {
        [useinfo setObject:errorMsg forKey:NSLocalizedDescriptionKey];
    }
    NSError *error = [[NSError alloc] initWithDomain:domain code:errorCode userInfo:useinfo];
    return error;
}

typedef void (^JKAliPayHelperResultBlock)(NSDictionary *);

@interface JKAliPayHelper()
@property (nonatomic,copy) NSString *appScheme;
@property (nonatomic,copy) JKAliPayHelperResultBlock resultBlock;

@end

@implementation JKAliPayHelper

static JKAliPayHelper *_helper = nil;
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [JKAliPayHelper new];
    });
    return _helper;
}

+ (void)conifgAppScheme:(NSString *)appScheme{
    [JKAliPayHelper shareInstance].appScheme = appScheme;
}

+ (void)pay:(NSString *)orderString success:(void(^)(NSString *msg))success failuer:(void(^)(NSError *))failure{
    [JKAliPayHelper shareInstance].resultBlock = ^(NSDictionary *resultDic){
        int resultStatus = [[resultDic objectForKey:@"resultStatus"] intValue];
        if (resultStatus == 9000) {//成功
            if (success) {
                success(@"支付成功");
            }
        }else{
            NSError *error = nil;
            if (resultStatus == 6001) {//取消
                error = JKErrorBuild(resultStatus,@"alipayError", @"支付取消");
            }else{//失败
                error = JKErrorBuild(resultStatus,@"alipayError", @"支付失败");
            }
            if (failure) {
                failure(error);
            }
        }
    };
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:[JKAliPayHelper shareInstance].appScheme callback:nil];
    
}

+ (void)pay:(NSString *)orderString dynamicLaunch:(BOOL)dynamicLaunch success:(void(^)(NSString *msg))success failuer:(void(^)(NSError *))failure{
    [JKAliPayHelper shareInstance].resultBlock = ^(NSDictionary *resultDic){
        int resultStatus = [[resultDic objectForKey:@"resultStatus"] intValue];
        if (resultStatus == 9000) {//成功
            if (success) {
                success(@"支付成功");
            }
        }else{
            NSError *error = nil;
            if (resultStatus == 6001) {//取消
                error = JKErrorBuild(resultStatus,@"alipayError", @"支付取消");
            }else{//失败
                error = JKErrorBuild(resultStatus,@"alipayError", @"支付失败");
            }
            if (failure) {
                failure(error);
            }
        }
    };
    [[AlipaySDK defaultService] payOrder:orderString dynamicLaunch:dynamicLaunch fromScheme:[JKAliPayHelper shareInstance].appScheme callback:nil];
}

+ (void)cleanBlock{
    [JKAliPayHelper shareInstance].resultBlock = nil;
}
+ (void)handleURL:(NSURL *)url{
    [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
        [JKAliPayHelper shareInstance].resultBlock(resultDic);
        [JKAliPayHelper cleanBlock];
    }];
}

@end
