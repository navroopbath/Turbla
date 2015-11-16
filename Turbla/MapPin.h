//
//  MapPin.h
//  Turbla
//
//  Created by Patricia S Demorest on 11/15/15.
//  Copyright © 2015 Turbla. All rights reserved.
//

@import MapKit;

#import <Foundation/Foundation.h>

@interface MapPin : NSObject <MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly, copy) NSString *title;
@property(nonatomic, readonly, copy) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description;

@end
