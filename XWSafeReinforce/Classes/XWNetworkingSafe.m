//
//  XWNetworkingSafe.m
//  Pods-XWSafeReinforce_Example
//
//  Created by WJF on 2019/7/4.
//

#import "XWNetworkingSafe.h"

@implementation XWNetworkingSafe

/**
 判断网络请求是否开启了代理(真机，模拟器未知)

 @return return value description
 */
+ (BOOL)xw_getProxyStatus{
    
    NSDictionary *proxySettings =  (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = CFBridgingRelease((__bridge CFTypeRef _Nullable)((__bridge NSArray *)CFNetworkCopyProxiesForURL((__bridge CFURLRef)[NSURL URLWithString:@"http://www.baidu.com"], (__bridge CFDictionaryRef)proxySettings)));
    
    NSDictionary *settings = [proxies objectAtIndex:0];
    NSLog(@"host=%@", [settings objectForKey:(NSString *)kCFProxyHostNameKey]);
    NSLog(@"port=%@", [settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
    NSLog(@"type=%@", [settings objectForKey:(NSString *)kCFProxyTypeKey]);
    
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]){
        //没有设置代理
        return NO;
    }else{
        //设置代理了
        return YES;
    }
}


/**
 判断当前是否有VPN进行连接

 @return return value description
 */
+(BOOL)xw_getVPNConnectedStatus{
    
    NSDictionary * proxySettings = (__bridge NSDictionary *)CFNetworkCopySystemProxySettings();
    NSLog(@"%@", proxySettings);
    NSArray * keys = [proxySettings[@"__SCOPED__"] allKeys];
    for (NSString * key in keys) {
        if ([key rangeOfString:@"tap"].location != NSNotFound ||
            [key rangeOfString:@"tun"].location != NSNotFound ||
            [key rangeOfString:@"ppp"].location != NSNotFound) {
            NSLog(@">>>>>>开启了VPN");
            return YES;
        }
    }
    NSLog(@">>>>>>没有开启VPN");
    return NO;
}


/**
 Auth验证jwt解析(decode)token原生方法
 
 @param jwtStr jwt
 @return return value description
 */
+(NSDictionary *)jwtDecodeWithJwtString:(NSString *)jwtStr{
    
    NSArray * segments = [jwtStr componentsSeparatedByString:@"."];
    NSString * base64String = [segments objectAtIndex:1];
    
    int requiredLength = (int)(4 *ceil((float)[base64String length]/4.0));
    int nbrPaddings = requiredLength - (int)[base64String length];
    if(nbrPaddings > 0){
        NSString * pading = [[NSString string] stringByPaddingToLength:nbrPaddings withString:@"=" startingAtIndex:0];
        base64String = [base64String stringByAppendingString:pading];
    }
    base64String = [base64String stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    NSData * decodeData = [[NSData alloc] initWithBase64EncodedData:base64String options:0];
    NSString * decodeString = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:[decodeString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    return jsonDict;
}

@end
