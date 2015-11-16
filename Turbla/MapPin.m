//
//  MapPin.m
//  Turbla
//
//  Created by Patricia S Demorest on 11/15/15.
//  Copyright © 2015 Turbla. All rights reserved.
//

#import "MapPin.h"

@interface MapPin ()

@property(nonatomic, readwrite, copy) NSString *title;
@property(nonatomic, readwrite, copy) NSString *subtitle;

@end

@implementation MapPin


- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)location placeName:placeName description:description {
    self = [super init];
    if (self != nil) {
        self.coordinate = location;
        self.title = placeName;
        self.subtitle = description;
    }
    return self;
}


@end
