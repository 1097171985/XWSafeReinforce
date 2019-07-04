//
//  main.m
//  XWSafeReinforce
//
//  Created by 1097171985 on 07/04/2019.
//  Copyright (c) 2019 1097171985. All rights reserved.
//

@import UIKit;
#import "XWAppDelegate.h"

#import <dlfcn.h>
#import <sys/types.h>
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

void disable_gdb() {
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

int main(int argc, char * argv[])
{
 
//阻止动态调试
#if !(DEBUG)
    disable_gdb();
#endif
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([XWAppDelegate class]));
    }
}
