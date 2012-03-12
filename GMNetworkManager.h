//
//  GMNetwork Kit
//
//  Created by Gersham Meharg on 11-02-13.
//  Copyright 2011 Gersham Meharg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMOperationResult.h"

#define SharedNetworkManager \
((GMNetworkManager *)[GMNetworkManager shared])

@class GMOperationResult;

extern NSString *const HTTPGet;
extern NSString *const HTTPPost;
extern NSString *const HTTPPut;
extern NSString *const HTTPDelete;

@interface GMNetworkManager : NSObject

typedef void (^OperationCallbackBlock)(GMOperationResult *);

+(GMNetworkManager *)shared;

@property (nonatomic, strong) NSOperationQueue *networkQueue;
@property (nonatomic, strong) NSString *apiEndpoint;
@property (nonatomic, strong) NSDate *lastAlertTime;
@property (nonatomic, assign) BOOL alertShown;

- (void)operationForPath:(NSString *)path 
              httpMethod:(NSString *)httpMethod
              parameters:(NSDictionary *)parameters 
              completion:(OperationCallbackBlock)completion;

- (void)operationForURL:(NSURL *)url 
             httpMethod:(NSString *)httpMethod
             parameters:(NSDictionary *)parameters 
             completion:(OperationCallbackBlock)completion;

- (void)showErrorAlertForResult:(GMOperationResult *)result;
- (void)showNetworkDownAlert;

@end
