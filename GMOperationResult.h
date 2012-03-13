//
//  GMNetwork Kit
//
//  Created by Gersham Meharg on 11-02-13.
//  Copyright 2011 Gersham Meharg. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "GMNetworkManager.h"

@interface GMOperationResult : NSObject

@property NSUInteger type;
@property NSUInteger httpCode;

@property (nonatomic, strong) id data;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDictionary *json;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSString *errorTitle;
@property (nonatomic, strong) NSString *errorDescription;
@property (nonatomic, strong) NSDictionary *parameters;

@property (nonatomic, strong) NSSet *allObjectIDs;
@property (nonatomic, strong) NSSet *createdObjectIDs;
@property (nonatomic, strong) NSSet *updatedObjectIDs;

@property (nonatomic, copy) id completion;

@end
