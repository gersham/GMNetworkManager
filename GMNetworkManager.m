//
//  GMNetwork Kit
//
//  Created by Gersham Meharg on 11-02-13.
//  Copyright 2011 Gersham Meharg. All rights reserved.
//

#import "GMNetworkManager.h"
#import "GMNetworkOperation.h"
#include <CommonCrypto/CommonDigest.h>
#import "NSString+URLEncode.h"

@implementation GMNetworkManager
static GMNetworkManager *shared = nil;

@synthesize apiEndpoint = _apiEndpoint;
@synthesize lastAlertTime = _lastAlertTime;
@synthesize alertShown = _alertShown;
@synthesize networkQueue = _networkQueue;
@synthesize defaultHeaders = _defaultHeaders;

NSString *const HTTPPost = @"POST";
NSString *const HTTPPut = @"PUT";
NSString *const HTTPGet = @"GET";
NSString *const HTTPDelete = @"DELETE";

- (void)operationForPath:(NSString *)path 
              httpMethod:(NSString *)httpMethod
              parameters:(NSDictionary *)parameters 
              completion:(void (^)(GMOperationResult *result))completion {

      if (parameters == nil)
          parameters = [NSMutableDictionary dictionaryWithCapacity:4];

  	// Build URL
  	NSString *location;
  	if ([parameters count] > 0 && (![httpMethod isEqualToString:HTTPPost] && ![httpMethod isEqualToString:HTTPPut])) {
          NSMutableString *args = [NSMutableString stringWithString:@"?"];
  		for (NSString *key in parameters) {
              if ([parameters objectForKey:key] == [NSNull null]) {
                  NSLog(@"Null value for %@ skipping", key);
                  continue;
              }
              NSString *value = [[parameters objectForKey:key] urlEncodedString];
  			[args appendString:[NSString stringWithFormat:@"%@=%@&", key, value]];
  		}	
  		location = [NSString stringWithFormat:@"%@%@%@", _apiEndpoint, path, [args substringWithRange:NSMakeRange(0, args.length-1)]];

  	} else { 
  		location = [NSString stringWithFormat:@"%@%@", _apiEndpoint, path];
  	}

  	NSURL *url = [[NSURL alloc] initWithString:location];
    
  [self operationForURL:url
             httpMethod:httpMethod
             parameters:parameters
             completion:completion];
}

- (void)operationForURL:(NSURL *)url 
             httpMethod:(NSString *)httpMethod
             parameters:(NSDictionary *)parameters 
             completion:(void (^)(GMOperationResult *result))completion {

    // Do Operation
    if (url != nil) {        
        GMNetworkOperation *op = [GMNetworkOperation new];
        op.delegate = self;
        op.url = url;
        op.parameters = parameters;
        op.httpMethod = httpMethod;
        op.completion = completion;
                
        [self.networkQueue addOperation:op];		
                            
    } else {
        NSLog(@"Not performing network operation for undefined url");
    }
}

- (void)networkOperationResult:(GMOperationResult *)result {
    if (result.error) {
        NSLog(@"NetOpp Error");
        OperationCallbackBlock block = (OperationCallbackBlock)result.completion;
        block(result);
        
    } else {
        OperationCallbackBlock block = (OperationCallbackBlock)result.completion;
        block(result);
    }
}

- (void)showErrorAlertForResult:(GMOperationResult *)result {
    
    if (result.httpCode == 401) {        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed" 
                                                        message:@"There was a problem authenticating you.  Please login again." 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        alert.tag = 6;
        [alert show];

        return;
    }
    
    if (self.lastAlertTime == nil || -[_lastAlertTime timeIntervalSinceNow] > 4) {
        self.lastAlertTime = [NSDate date];
        self.alertShown = YES;
        NSLog(@"NetworkOperationResult Error %@ - %@", result.errorTitle, result.errorDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:result.errorTitle
                                                        message:result.errorDescription 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        alert.tag = 2;
        [alert show];
    }
}
    
- (void)showNetworkDownAlert {
    if (self.lastAlertTime == nil || -[_lastAlertTime timeIntervalSinceNow] > 4) {
        self.lastAlertTime = [NSDate date];
        self.alertShown = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"503 Service Down" 
                                                        message:@"The webservice is currently down for maintainence, please try again later.  Sorry for the inconvienience" 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        alert.tag = 5;
        [alert show];
    }
}
    
#pragma mark Singleton
+ (id)shared {
	@synchronized(self) {
		if(shared == nil)
			shared = [[super allocWithZone:NULL] init];
	}
	return shared;
}

- (id)init {
	if ((self = [super init])) {
        self.networkQueue = [NSOperationQueue new];
        [self.networkQueue setMaxConcurrentOperationCount:5];
        self.defaultHeaders = [NSMutableDictionary dictionary];
	}
	return self;
}

@end
