//
//  ViewController.m
//  JYBox
//
//  Created by JackYang on 2017/10/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "ViewController.h"
#import "CocoaSecurity.h"
#import "FileHash.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString * s = @"123";
//    NSData * data = [s dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@",[CocoaSecurity sha256WithData:data].hex);
//    NSString * p = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    p = [NSString stringWithFormat:@"%@/123", p];
//    [data writeToFile:p atomically:YES];
//    NSLog(@"%@", [FileHash sha256HashOfFileAtPath:p]);
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
