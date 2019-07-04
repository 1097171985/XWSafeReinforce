//
//  XWNetworkingSafe.h
//  Pods-XWSafeReinforce_Example
//
//  Created by WJF on 2019/7/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XWNetworkingSafe : NSObject

/**
 判断网络请求是否开启了代理(真机已测，模拟器未知)
 
 @return return value description
 */
+(BOOL)xw_getProxyStatus;


/**
 判断当前是否有VPN进行连接
 
 @return return value description
 */
+(BOOL)xw_getVPNConnectedStatus;



/**
  Auth验证jwt解析(decode)token原生方法

 @param jwtStr jwt
 @return return value description
 */
+(NSDictionary *)jwtDecodeWithJwtString:(NSString *)jwtStr;


@end

NS_ASSUME_NONNULL_END
