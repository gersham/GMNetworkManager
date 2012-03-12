//
//  GMNetwork Kit
//
//  Created by Gersham Meharg on 11-02-13.
//  Copyright 2011 Gersham Meharg. All rights reserved.
//

#import "GMOperationResult.h"

@implementation GMOperationResult
@synthesize httpCode = _httpCode;
@synthesize json = _json;
@synthesize data = _data;
@synthesize image = _image;
@synthesize error = _error;
@synthesize type = _type;
@synthesize parameters = _parameters;
@synthesize url = _url;
@synthesize errorTitle = _errorTitle;
@synthesize errorDescription = _errorDescription;
@synthesize allObjectIDs = _allObjectsIDs;
@synthesize createdObjectIDs = _createdObjectIDs;
@synthesize updatedObjectIDs = _updatedObjectIDs;
@synthesize completion = _completion;

- (NSString *)description {
	if (self.error) {
		return [NSString stringWithFormat:@"OperationResult code:%i error:%@", self.httpCode, self.error];
	} else {
		return [NSString stringWithFormat:@"OperationResult code:%i json-count:%i", self.httpCode, self.json.count];
	}
}

@end
