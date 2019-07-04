//
//  XWDeviceSafe.m
//  Pods-XWSafeReinforce_Example
//
//  Created by WJF on 2019/7/4.
//

#import "XWDeviceSafe.h"
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#include <CommonCrypto/CommonDigest.h>

#define FileHashDefaultChunkSizeForReadingData 1024*8

@implementation XWDeviceSafe

/**
 只能做简单的检查设备是否越狱

 @return return value description
 */
+ (BOOL)xw_isJailbroken {
    // 检查是否存在越狱常用文件
    NSArray *jailFilePaths = @[@"/Applications/Cydia.app",
                               @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                               @"/bin/bash",
                               @"/usr/sbin/sshd",
                               @"/etc/apt"];
    for (NSString *filePath in jailFilePaths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return YES;
        }
    }
    // 检查是否安装了越狱工具Cydia
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]){
        return YES;
    }
    // 检查是否有权限读取系统应用列表
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Applications/"]){
        NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/User/Applications/"
                                                                        error:nil];
        NSLog(@"applist = %@",applist);
        return YES;
    }
    //  检测当前程序运行的环境变量
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env != NULL) {
        return YES;
    }
    return NO;
}


/**
 只能做简单的判断ipa是否被二次打包

 @return return value description
 */
+ (BOOL)xw_isSecondIpa{
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    if ([info objectForKey:@"SignerIdentity"] != nil) {
        //存在这个key ,则说明被二次打包了
        return YES;
    }
    return NO;
}



//MARK:反调试测试 直接参考以下代码即可
//以下是 0x01 ptrace 的调试检测

//#import <dlfcn.h>
//#import <sys/types.h>
//
//typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
//#if !defined(PT_DENY_ATTACH)
//#define PT_DENY_ATTACH 31
//#endif  // !defined(PT_DENY_ATTACH)
//
//void disable_gdb() {
//    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
//    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
//    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
//    dlclose(handle);
//}
//
//int main(int argc, char *argv[]) {
//    // Don't interfere with Xcode debugging sessions.
//#if !(DEBUG)
//    disable_gdb();
//#endif
//
//    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil,
//                                 NSStringFromClass([XWAppDelegate class]));
//    }
//}


//以下是 0x02 syscall 的调试检测
//调用syscall(26,31,0,0,0)就可以达到反调试的目的。


//以下是 0x03 sysctl  的调试检测 可以在多处地方添加此方法 增加调试点点难度
/**
 反调试测试 3 ，在多处地方添加此方法 增加调试点点难度

 @return return value description
 */
+ (BOOL)xw_existOnlineApiDebugging{
    
    int name[4];//指定查询信息的数组
    struct kinfo_proc info;//查询的返回结果
    size_t info_size = sizeof(info);
    info.kp_proc.p_flag = 0;
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
        NSLog(@"sysctl error ...");
        return NO;
    }
    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}



//MARK:对于文件进行MD5加密跟后台进行校验，防止文件被篡改
/**
 对于文件进行MD5加密跟后台进行校验，防止文件被篡改

 @param filepath 文件路径
 @return return value description
 */
+(NSString*)getFileMD5WithPath:(NSString*)filepath{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)filepath, FileHashDefaultChunkSizeForReadingData);
}


CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

@end
