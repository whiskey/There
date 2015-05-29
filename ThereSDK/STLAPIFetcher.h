//
//  STLAbstractFetcher.h
//  There
//
//  Created by Carsten Witzke on 25/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

@import Foundation;
@import MapKit;

#import "AFNetworking.h"

@interface STLAPIFetcher : AFHTTPRequestOperationManager
- (instancetype)initWithBaseURL:(NSURL *)url appID:(NSString *)appID appCode:(NSString *)appCode;
@end
