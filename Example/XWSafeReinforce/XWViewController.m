//
//  XWViewController.m
//  XWSafeReinforce
//
//  Created by 1097171985 on 07/04/2019.
//  Copyright (c) 2019 1097171985. All rights reserved.
//

#import "XWViewController.h"

#import <XWSafeReinforce/XWNetworkingSafe.h>

@interface XWViewController ()

@end

@implementation XWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//
    NSString *jwt = @"eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxODYgKioqKiA1MzU2IiwiaXVhIjoi5bCP6Jm-57GzX0xlZSIsImNyZWF0ZWQiOjE1NTMwNTAwMzE1MjMsImV4cCI6MTU1MzEzNjQzMSwidXNlcklkIjoiYzI5MmMxZjU4NjE4NGRkN2JlMzNiODBiNTIwOWZiZGEiLCJhdXRob3JpdGllcyI6W3siYXV0aG9yaXR5IjoiUk9MRV9BUFAifV19.i74NZk8o4NUfRh9tIdEJn8axHNASOQoozkv5QDdH1h4-ZSGv1Mu_DVN8NKEY-9M683-MWn2Hz8Vi7XRXPiCFsA";
    
    NSDictionary *dict = [XWNetworkingSafe jwtDecodeWithJwtString:jwt];
    NSLog(@"===%@",dict);
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
