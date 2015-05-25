//
//  STLRouteFetcher.m
//  There
//
//  Created by Carsten Witzke on 25/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

#import "STLRouteFetcher.h"

@implementation STLRouteRequest
@end


@implementation STLRouteFetcher

- (instancetype)init {
#if DEBUG
    NSURL *baseURL = [NSURL URLWithString:@"http://route.cit.api.here.com"];
#else
#warning using Demo API instead of Production (http://route.api.here.com)
    NSURL *baseURL = [NSURL URLWithString:@"http://route.cit.api.here.com"];
#endif
    return [super initWithBaseURL:baseURL];
}

#pragma mark - STLRouteRequestProtocol

- (void)routeWithRequest:(STLRouteRequest *)request complete:(void (^)(NSArray *, NSError *))completionBlock {
    NSUInteger wpCount = request.waypoints.count;
    NSAssert(wpCount>0, @"must have at least one waypoint");
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:wpCount];
    // waypoints
    for (int i=0; i<wpCount; i++) {
        CLLocation *loc = request.waypoints[i];
        // quick and dirty GeoWaypointParameterType
        NSString *waypoint = [NSString stringWithFormat:@"geo!%f,%f", loc.coordinate.latitude, loc.coordinate.longitude];
        [params setObject:waypoint forKey:[NSString stringWithFormat:@"waypoint%ld",(long)i]];
    }
    // additional parameters
    [params addEntriesFromDictionary:request.parameters];
    
    [self GET:@"routing/7.2/calculateroute.json"
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (completionBlock) {
                  NSArray *navPoints = @[];
                  completionBlock(navPoints, nil);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (completionBlock) {
                  completionBlock(nil, error);
              }
          }];
}

@end
