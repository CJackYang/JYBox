//
//  JBPhotoService.h
//  JYBox
//
//  Created by JackYang on 2017/10/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBPhotoService : NSObject

@end

@interface JBPhotoHashWorker : NSObject

@property (nonatomic) NSMutableArray * paddingQueue;

@property (nonatomic) NSMutableArray * workingQueue;

@property (nonatomic) NSMutableArray * finishedQueue;

@property (nonatomic) NSInteger limitCount; // default 4

- (void) schedule;

- (void) stop;

- (void) abort;

//- (void) pause;

@end

@interface JBPhotoUploader : NSObject

@property (nonatomic) NSMutableArray * paddingQueue;

@property (nonatomic) NSMutableArray * workingQueue;

@property (nonatomic) NSMutableArray * finishedQueue;

@property (nonatomic) NSInteger limitCount; // default 1

- (void) schedule;

- (void) stop;

- (void) abort;

@end
