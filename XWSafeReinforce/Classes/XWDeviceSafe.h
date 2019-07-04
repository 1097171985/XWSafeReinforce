//
//  XWDeviceSafe.h
//  Pods-XWSafeReinforce_Example
//
//  Created by WJF on 2019/7/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XWDeviceSafe : NSObject

/**
 只能做简单的检查设备是否越狱
 
 @return return value description
 */
+ (BOOL)xw_isJailbroken;


/**
 只能做简单的判断ipa是否被二次打包
 
 @return return value description
 */
+ (BOOL)xw_isSecondIpa;


/**
 反调试测试 3 ，在多处地方添加此方法 增加调试点点难度
 
 @return return value description
 */
+ (BOOL)xw_existOnlineApiDebugging;


/**
 对于文件进行MD5加密跟后台进行校验，防止文件被篡改，
 不知道会不会造成内存崩溃
 
 @param filepath 文件路径
 @return return value description
 */
+(NSString*)getFileMD5WithPath:(NSString*)filepath;


@end

NS_ASSUME_NONNULL_END
