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

@implementation STLNavPoint
@end

@implementation STLRouteFetcher

- (instancetype)initWithAppID:(NSString *)appID appCode:(NSString *)appCode {
#if DEBUG
    NSURL *baseURL = [NSURL URLWithString:@"http://route.cit.api.here.com"];
#else
#warning using Demo API instead of Production (http://route.api.here.com)
    NSURL *baseURL = [NSURL URLWithString:@"http://route.cit.api.here.com"];
#endif
    self = [super initWithBaseURL:baseURL];
    [self.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, id parameters, NSError *__autoreleasing *error) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
        NSMutableArray *queryItems = [NSMutableArray array];
        // no auth header here... m(
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"app_id" value:appID]];
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"app_code" value:appCode]];
        
        for (NSString *key in [parameters allKeys]) {
            NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:parameters[key]];
            [queryItems addObject:item];
        }
        [components setQueryItems:queryItems];
        return components.URL.absoluteString;
    }];
    return self;
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
                  NSMutableArray *navPoints = [NSMutableArray array];
                  for (NSDictionary *route in [responseObject valueForKeyPath:@"response.route"]) {
                      for (NSDictionary *leg in [route valueForKey:@"leg"]) {
                          for (NSDictionary *position in [leg valueForKeyPath:@"maneuver.position"]) {
                              STLNavPoint *nav = [STLNavPoint new];
                              CLLocationDegrees lat = [position[@"latitude"] doubleValue];
                              CLLocationDegrees lng = [position[@"longitude"] doubleValue];
                              nav.location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
                              [navPoints addObject:nav];
                          }
                      }
                  }
                  completionBlock(navPoints, nil);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (completionBlock) {
                  completionBlock(nil, error);
              }
          }];
}

@end
