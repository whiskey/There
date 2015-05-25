//
//  STLAPIHandler.m
//  There
//
//  Created by Carsten Witzke on 25/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

#import "STLAPIHandler.h"

#if DEBUG
static NSString *kAPIEndpoint = @"https://places.cit.api.here.com";
static BOOL isProductionEnvironment = NO;
#else
#warning using Demo API instead of Production (http://places.api.here.com)
static NSString *kAPIEndpoint = @"https://places.cit.api.here.com";
static BOOL isProductionEnvironment = YES;
#endif

@interface STLAPIHandler ()
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (copy, nonatomic) NSString *appID;
@property (copy, nonatomic) NSString *appCode;
@end

@implementation STLAPIHandler

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static STLAPIHandler *_sharedObject = nil;
    
    dispatch_once(&pred, ^{
        NSURL *baseURL = [NSURL URLWithString:kAPIEndpoint];
        STLAPIHandler *fetcher = [[STLAPIHandler alloc]  initWithBaseURL:baseURL];
        fetcher.requestSerializer = [AFJSONRequestSerializer serializer];
        fetcher.responseSerializer = [AFJSONResponseSerializer serializer];
        // Let AF serializers handle HTTP headers like
        // Accept (here: application/json),  Accept-Language and others
        
        // set global headers
        NSString *isDev = isProductionEnvironment? @"0" : @"1";
        [fetcher.requestSerializer setValue:isDev forHTTPHeaderField:@"X-NLP-Testing"];
        
        _sharedObject = fetcher;
    });
    
    return _sharedObject;
}

+ (void)setAppID:(NSString *)appID appCode:(NSString *)appCode {
    STLAPIHandler *fetcher = [STLAPIHandler sharedInstance];
    fetcher.appID = appID;
    fetcher.appCode = appCode;
    
    NSString *combined = [NSString stringWithFormat:@"%@:%@", appID, appCode];
    NSString *token = [NSString stringWithFormat:@"Basic %@", [[combined dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
    [fetcher.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
}

@end
