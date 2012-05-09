//
//  GMNetwork Kit
//
//  Created by Gersham Meharg on 11-02-13.
//  Copyright 2011 Gersham Meharg. All rights reserved.
//


#import "GMNetworkOperation.h"
#import "GMNetworkManager.h"
#import "GMOperationResult.h"
#import "NSString+URLEncode.h"

@implementation GMNetworkOperation
@synthesize url = _url;
@synthesize parameters = _parameters;
@synthesize delegate = _delegate;
@synthesize httpMethod = _httpMethod;
@synthesize jsonString = _jsonString;
@synthesize result = _result;
@synthesize completion = _completion;
@synthesize parseResults = _parseResults;

- (id)init {
	self = [super init];
	self.httpMethod = HTTPGet;
	self.parameters = [NSMutableDictionary dictionaryWithCapacity:4];
	return self;
}

- (void)setJsonData:(id)data {
	self.jsonString = [data jsonString];
}

- (void)main
{
    [NSThread setThreadPriority:0];
    
    if ([self isCancelled]) {
        NSLog(@"Operation is cancelled");
        return;
    }
    
	NSLog(@"* REQ %@", _url);
		
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                       timeoutInterval:20.0];
    
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:NO];
        
	// JSON PUT/POST
	if (self.jsonString) {		
		
		NSData *body = [self.jsonString dataUsingEncoding:NSUTF8StringEncoding]; 
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:body];

	// Regular POST/PUT
	} else if (self.httpMethod == @"POST" || self.httpMethod == @"PUT") {		
		
        NSLog(@"* PARAMETERS %@", _parameters);

        NSString *formPostParams = [self encodeFormPostParameters:_parameters];
        [request setValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField: @"Content-Type"];
        [request setHTTPBody:[formPostParams dataUsingEncoding:NSUTF8StringEncoding]];

    // Other Methods
	} else {
	}
	
    
    NSString *version = [NSString stringWithFormat:@"%@-%@",
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];

    [request setValue:version forHTTPHeaderField:@"APP_VERSION"];
    
    // Set headers from the network manager
    NSMutableDictionary *defaultHeaders = [SharedNetworkManager.defaultHeaders mutableCopy];
    for (NSString *key in defaultHeaders.allKeys) {
        [request setValue:[defaultHeaders valueForKey:key] forHTTPHeaderField:key];
    }
    
    [request setHTTPMethod:_httpMethod];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSError *error = nil;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if ([self isCancelled]) {
        NSLog(@"Operation is cancelled");
        return;
    }

    //NSLog(@"* RES %i %@", [response statusCode], _url);

	// Build the result
	self.result = [GMOperationResult new];
	_result.httpCode = [response statusCode];
	_result.parameters = _parameters;
	_result.url = _url;
    _result.completion = _completion;
    
	// Handle Errors
	if (error != nil || _result.httpCode < 200 || _result.httpCode > 299) {
		        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithCapacity:2];
		
		if (_result.httpCode == 401) {
			[errorInfo setObject:@"Authentication Failure" forKey:NSLocalizedDescriptionKey];
			[errorInfo setObject:@"The supplied API Key was not found" forKey:NSLocalizedFailureReasonErrorKey];
			
        } else if (error.code == -1012) {
            _result.httpCode = 401;
			[errorInfo setObject:@"Authentication Failure" forKey:NSLocalizedDescriptionKey];
			[errorInfo setObject:@"The supplied API Key was not found" forKey:NSLocalizedFailureReasonErrorKey];
        
		} else if (error != nil) {
			[errorInfo setObject:@"Connection Error" forKey:NSLocalizedDescriptionKey];
			[errorInfo setObject:error.localizedDescription forKey:NSLocalizedFailureReasonErrorKey];
            NSLog(@"Connection Error, %@", error);
			
		} else {
            NSLog(@"* Error %i %@", _result.httpCode, responseString);
			switch (_result.httpCode) {
				case 400:
					[errorInfo setObject:@"Bad Request" forKey:NSLocalizedDescriptionKey];
					[errorInfo setObject:responseString forKey:NSLocalizedFailureReasonErrorKey];
					break;
                    
                case 403:
                    [errorInfo setObject:@"Forbidden" forKey:NSLocalizedDescriptionKey];
					[errorInfo setObject:responseString forKey:NSLocalizedFailureReasonErrorKey];
					break;

                case 404:
                    [errorInfo setObject:@"Not Found" forKey:NSLocalizedDescriptionKey];
					[errorInfo setObject:responseString forKey:NSLocalizedFailureReasonErrorKey];
					break;
                    
                case 405:
                    [errorInfo setObject:@"Method Not Allowed" forKey:NSLocalizedDescriptionKey];
					[errorInfo setObject:responseString forKey:NSLocalizedFailureReasonErrorKey];
					break;
                    
                case 409:
                    [errorInfo setObject:@"Conflict" forKey:NSLocalizedDescriptionKey];
					[errorInfo setObject:responseString forKey:NSLocalizedFailureReasonErrorKey];
					break;

                case 491:
                case 492:
                case 493:
                case 494:
                case 495:
                case 496:
                case 497:
                case 498:
                case 499:
                    [errorInfo setObject:@"Special Error" forKey:NSLocalizedDescriptionKey];
					[errorInfo setObject:responseString forKey:NSLocalizedFailureReasonErrorKey];
					break;

				case 500:
				case 501:
				case 502:
				case 503:
				case 504:
                    NSLog(@"* 50x Error from server \n\n %@ \n\n", responseString);
					[errorInfo setObject:@"Server Error" forKey:NSLocalizedDescriptionKey];
					[errorInfo setObject:[NSString stringWithFormat:@"Error attempting to communicate to server (%i).  Please try again later.", _result.httpCode] forKey:NSLocalizedFailureReasonErrorKey];
					break;
					
				default:
					[errorInfo setObject:@"Connection Error" forKey:NSLocalizedDescriptionKey];
					[errorInfo setObject:[NSString stringWithFormat:@"Error attempting to communicate to server (%i).  Please try again later.", _result.httpCode] forKey:NSLocalizedFailureReasonErrorKey];
					break;
			}
		}
		_result.error = [NSError errorWithDomain:@"NetworkOperationError" code:_result.httpCode userInfo:errorInfo];
        _result.errorTitle = [_result.error.userInfo objectForKey:NSLocalizedDescriptionKey];
        _result.errorDescription = [_result.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];

        // Try to parse out a JSON error message
        if (data != nil) {
            NSError *error = nil;
            _result.json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error == nil && [_result.json valueForKey:@"error_message"]) {
                _result.errorDescription = [_result.json valueForKey:@"error_message"];
            }
        }

	} else {
        NSError *error = nil;
        _result.json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error != nil) {
            NSLog(@"Error parsing JSON %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
      		NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            [errorInfo setObject:@"JSON Parsing Error" forKey:NSLocalizedDescriptionKey];
            [errorInfo setObject:@"Error parsing JSON" forKey:NSLocalizedFailureReasonErrorKey];
      		_result.error = [NSError errorWithDomain:@"NetworkOperationError" code:_result.httpCode userInfo:errorInfo];
            _result.errorTitle = [_result.error.userInfo objectForKey:NSLocalizedDescriptionKey];
            _result.errorDescription = [_result.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
        }
	}
	    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
	// Send the result to the delegate
	if ([_delegate respondsToSelector:@selector(networkOperationResult:)]) {
		[_delegate performSelectorOnMainThread:@selector(networkOperationResult:) withObject:_result waitUntilDone:YES];
        
	} else if (_delegate != nil) {
		NSLog(@"* Delegate doesn't respond to networkOperationResult");
	}	
}


- (NSString *)encodeFormPostParameters: (NSDictionary *)postParameters {
    NSMutableString *formPostParams = [[NSMutableString alloc] init];
    
    NSEnumerator *keys = [postParameters keyEnumerator];
    
    NSString *name = [keys nextObject];
    while (nil != name) {
        
        NSString *encodedValue = [NSString stringWithString:[postParameters valueForKey:name]];
        if ([encodedValue isMemberOfClass:[NSString class]]) {
            encodedValue = [encodedValue urlEncodedString];
        }
        
        [formPostParams appendString: name];
        [formPostParams appendString: @"="];
        [formPostParams appendString: encodedValue];
        
        name = [keys nextObject];
        
        if (nil != name) {
            [formPostParams appendString: @"&"];
        }
    }
    return formPostParams;
}


@end
