//
//  STLAbstractFetcher.m
//  There
//
//  Created by Carsten Witzke on 25/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

#import "STLAPIFetcher.h"

#if DEBUG
static BOOL isProductionEnvironment = NO;
#else
static BOOL isProductionEnvironment = YES;
#endif

@implementation STLAPIFetcher

- (instancetype)initWithBaseURL:(NSURL *)url appID:(NSString *)appID appCode:(NSString *)appCode {
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        // Let AF serializers handle HTTP headers like
        // Accept (here: application/json),  Accept-Language and others
        
        // authentication
        NSString *combined = [NSString stringWithFormat:@"%@:%@", appID, appCode];
        NSString *token = [NSString stringWithFormat:@"Basic %@", [[combined dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
        [self.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
        
        // set global headers
        NSString *isDev = isProductionEnvironment? @"0" : @"1";
        [self.requestSerializer setValue:isDev forHTTPHeaderField:@"X-NLP-Testing"];
    }
    return self;
}


@end
