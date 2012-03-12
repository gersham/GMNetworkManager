//
//  GMNetwork Kit
//
//  Created by Gersham Meharg on 11-02-13.
//  Copyright 2011 Gersham Meharg. All rights reserved.
//


#import <UIKit/UIKit.h>

enum {
    HTTP_GET,
    HTTP_PUT,
    HTTP_POST,
    HTTP_DELETE
};

@class GMOperationResult;

@interface GMNetworkOperation : NSOperation 

@property (nonatomic, weak) id delegate;
@property (nonatomic, copy) id completion;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSString *jsonString;
@property (nonatomic, assign) BOOL parseResults;
@property (nonatomic, strong) GMOperationResult *result;

- (NSString *)encodeFormPostParameters: (NSDictionary *) parameters;

@end

