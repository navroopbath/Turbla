//
//  EnRouteViewController.h
//  Turbla
//
//  Created by Patricia S Demorest on 11/15/15.
//  Copyright © 2015 Turbla. All rights reserved.
//

@import MapKit;

#import <UIKit/UIKit.h>

@interface EnRouteViewController : UIViewController

@property (nonatomic) NSString *destinationAddress;
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;

@end
