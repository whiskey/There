//
//  STLRouteFetcher.m
//  There
//
//  Created by Carsten Witzke on 25/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

#import "STLRouteFetcher.h"

@implementation STLRouteFetcher

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
    
    [self.api GET:@"routing/7.2/calculateroute.json"
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
