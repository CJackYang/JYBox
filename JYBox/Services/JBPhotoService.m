//
//  JBPhotoService.m
//  JYBox
//
//  Created by JackYang on 2017/10/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JBPhotoService.h"

@implementation JBPhotoService

- (instancetype)init {
    self = [super init];
    return self;
}

@end

@interface JBPhotoHashWorker()

@end

@implementation JBPhotoHashWorker

- (instancetype) init
{
    if(self = [super init]){
        self.limitCount = 4;
        self.paddingQueue = [NSMutableArray arrayWithCapacity:0];
        self.workingQueue = [NSMutableArray arrayWithCapacity:0];
        self.finishedQueue = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void) schedule
{
    
}

- (void) stop
{
    
}

- (void) abort
{
    
}


@end

@implementation JBPhotoUploader

- (instancetype) init
{
    if(self = [super init]){
        self.limitCount = 4;
        self.paddingQueue = [NSMutableArray arrayWithCapacity:0];
        self.workingQueue = [NSMutableArray arrayWithCapacity:0];
        self.finishedQueue = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void) schedule
{
    
}

- (void) stop
{
    
}

- (void) abort
{
    
}

@end
