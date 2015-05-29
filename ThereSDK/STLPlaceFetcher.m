//
//  STLPlaceFetcher.m
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

#import "STLPlaceFetcher.h"


@implementation STLPlaceRequest
- (NSString *)queryString {
    return [_queryString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}
@end

@implementation STLLinkObject

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        // super simple "parser" - don't treat this thing serious!
        self.identifier = [dict valueForKey:@"id"];
        NSAssert(self.identifier, @"must have an identifier!");
        
        self.href = [dict valueForKey:@"href"];
        
        NSArray *coordinates = [dict valueForKey:@"position"];
        if (coordinates.count >= 2) {
            self.coordinate = CLLocationCoordinate2DMake([coordinates[0] doubleValue], [coordinates[1] doubleValue]);
        }
        
        self.title = [dict valueForKey:@"title"];
        self.vicinity = [dict valueForKey:@"vicinity"];
        self.distanceInMeters = [[dict valueForKey:@"distance"] integerValue];
        // better:
        // generate parsers & validators based on the object's XML schema
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    NSDictionary *dict = @{ @"id": identifier };
    return [self initWithDictionary:dict];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[STLLinkObject class]]) {
        return NO;
    }
    
    return [self.identifier isEqualToString:[(STLLinkObject *)object identifier]];
}

- (NSUInteger)hash {
    return self.identifier.hash;
}

@end


@implementation STLPlaceFetcher

- (instancetype)initWithAppID:(NSString *)appID appCode:(NSString *)appCode {
#if DEBUG
    NSURL *baseURL = [NSURL URLWithString:@"https://places.cit.api.here.com"];
#else
#warning using Demo API instead of Production (http://places.api.here.com)
    NSURL *baseURL = [NSURL URLWithString:@"https://places.cit.api.here.com"];
#endif
    return [super initWithBaseURL:baseURL appID:appID appCode:appCode];
}

#pragma mark - STLPlaceRequestProtocol

- (void)searchSuggestionsForQuery:(STLPlaceRequest *)request complete:(void (^)(NSArray *suggestions, NSError *error))completionBlock {
    [self updateHTTPHeadersForRequest:request];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                  @"q": request.queryString,
                                                                                  @"tf": @"plain",
                                                                                  }];
    NSString *at = [[self geoURIForLocation:request.location] stringByReplacingOccurrencesOfString:@"geo:" withString:@""];
    [params setObject:at forKey:@"at"];
    
    [self GET:@"places/v1/suggest" parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (completionBlock != nil) {
              completionBlock([responseObject valueForKey:@"suggestions"], nil);
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", operation.responseObject);
          if (completionBlock != nil) {
              completionBlock(nil, error);
          }
      }];
}

- (void)searchPlacesWithQuery:(STLPlaceRequest*)request complete:(void (^)(NSArray *items, NSError *error))completionBlock {
    [self updateHTTPHeadersForRequest:request];
    
    NSDictionary *params = @{
                             @"q": request.queryString,
                             @"tf": @"plain",
                             };
    // I would prefer /suggestions
    [self GET:@"places/v1/discover/search" parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (completionBlock != nil) {
              NSMutableArray *items = [NSMutableArray array];
              for (NSDictionary *dict in [responseObject valueForKeyPath:@"results.items"]) {
                  STLLinkObject *item = [[STLLinkObject alloc] initWithDictionary:dict];
                  [items addObject:item];
              }
              completionBlock([NSArray arrayWithArray:items], nil);
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", operation.responseObject);
          if (completionBlock != nil) {
              completionBlock(nil, error);
          }
      }];
}

#pragma mark - request handling

- (void)updateHTTPHeadersForRequest:(STLPlaceRequest *)request {
    // implicit region, e.g. map viewport
    MKMapRect mRect = request.mapRect;
    MKMapPoint swMapPoint = MKMapPointMake(mRect.origin.x, MKMapRectGetMaxY(mRect));
    MKMapPoint neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), mRect.origin.y);
    CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
    CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
    NSString *regionString = [NSString stringWithFormat:@"%f,%f,%f,%f",
                              swCoord.latitude, swCoord.longitude,
                              neCoord.latitude, neCoord.longitude];
    [self.requestSerializer setValue:regionString forHTTPHeaderField:@"X-Map-Viewport"];
    
    // explicit location
    NSString *uri = [self geoURIForLocation:request.location];
    [self.requestSerializer setValue:uri forHTTPHeaderField:@"Geolocation"];
}

- (NSString *)geoURIForLocation:(CLLocation *)location {
    NSString *locString = nil;
    if (location) {
        locString = [NSString stringWithFormat:@"geo:%f,%f;u=%f",
                     location.coordinate.latitude,
                     location.coordinate.longitude,
                     location.horizontalAccuracy];
    }
    return locString;
}

@end
