//
//  STLPlaceFetcher.m
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

#import "STLPlaceFetcher.h"
#import "There-Swift.h"

@implementation STLPlaceRequest
- (NSString *)queryString {
    return [_queryString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}
@end


@implementation STLPlaceFetcher

#pragma mark - STLPlaceRequestProtocol

- (void)searchSuggestionsForQuery:(STLPlaceRequest *)request complete:(void (^)(NSArray *suggestions, NSError *error))completionBlock {
    [self updateHTTPHeadersForRequest:request];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                  @"q": request.queryString,
                                                                                  @"tf": @"plain",
                                                                                  }];
    NSString *at = [[self geoURIForLocation:request.location] stringByReplacingOccurrencesOfString:@"geo:" withString:@""];
    [params setObject:at forKey:@"at"];
    
    [self.api GET:@"places/v1/suggest" parameters:params
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
    [self.api GET:@"places/v1/discover/search" parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (completionBlock != nil) {
              NSMutableArray *items = [NSMutableArray array];
              for (NSDictionary *dict in [responseObject valueForKeyPath:@"results.items"]) {
                  GeoItem *item = [[GeoItem alloc] initWithDictionary:dict];
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
    [self.api.requestSerializer setValue:regionString forHTTPHeaderField:@"X-Map-Viewport"];
    
    // explicit location
    NSString *uri = [self geoURIForLocation:request.location];
    [self.api.requestSerializer setValue:uri forHTTPHeaderField:@"Geolocation"];
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
