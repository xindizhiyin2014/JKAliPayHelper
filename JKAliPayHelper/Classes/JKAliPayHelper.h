//
//  JKAliPayHelper.h
//  JKAliPayHelper
//
//  Created by JackLee on 2019/3/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKAliPayHelper : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)shareInstance;

+ (void)conifgAppScheme:(NSString *)appScheme;

+ (void)pay:(NSString *)orderString success:(void(^)(NSString *msg))success failuer:(void(^)(NSError *))failure;

+ (void)pay:(NSString *)orderString dynamicLaunch:(BOOL)dynamicLaunch success:(void(^)(NSString *msg))success failuer:(void(^)(NSError *))failure;


+ (void)handleURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
