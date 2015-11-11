//
//  AcceptPickupViewController.m
//  Turbla
//
//  Created by Patricia S Demorest on 11/8/15.
//  Copyright © 2015 Turbla. All rights reserved.
//

#import "AcceptPickupViewController.h"

@import MapKit;

@interface AcceptPickupViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSString *pickUpAddress;
@property (nonatomic) NSTimer *pickUpTimer;

@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) IBOutlet UILabel *noAvailablePickUpsLabel;

// layered views when pick up is available
@property (nonatomic) IBOutlet UIView *greyShield;
@property (nonatomic) IBOutlet UILabel *pickUpAddressLabel;
@property (nonatomic) IBOutlet UIView *timerContainer;
@property (nonatomic) IBOutlet UIButton *acceptPickUpButton;

@end

@implementation AcceptPickupViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUpLocationManager];
    [self setUpPrettyViews];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    // disclaimer: a lot of hardcoded stuff, this is not fully functional; for demonstration purposes only
    self.pickUpAddress = NSLocalizedString(@"Pick up available at Rebecca Minkoff - 2124 Fillmore St, San Francisco, CA 94115", nil);
    self.pickUpTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(displayNewPickUp) userInfo:nil repeats:NO];
    
}

#pragma mark - Set up
- (void)setUpPrettyViews {
    
    self.noAvailablePickUpsLabel.layer.cornerRadius = 3.0f;
    self.acceptPickUpButton.layer.cornerRadius = 5.0f;
}

- (void)setUpLocationManager {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
}

#pragma mark - New pick up

- (void)displayNewPickUp {
    
    self.noAvailablePickUpsLabel.hidden = YES;
    self.pickUpAddressLabel.text = self.pickUpAddress;
    
    [self.view addSubview:self.greyShield];
    self.greyShield.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add the constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.greyShield attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.greyShield attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.greyShield attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.greyShield attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    
    // force the layout to happen before the animation (otherwise drawing views doesn't happen until execution returns to the main event loop)
    [self.view layoutIfNeeded];
    
    // fade in the views
    self.greyShield.alpha = 0.0f;
    [UIView animateWithDuration:0.3f animations:^{
        self.greyShield.alpha = 0.7f;
    }];
    
}

#pragma mark - CLLLocationManagerDelegate

// PSD TODO: this delegate method not getting called
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    MKCoordinateRegion userRegion = MKCoordinateRegionMake(newLocation.coordinate, MKCoordinateSpanMake(0.2, 0.2));
    [self.mapView setRegion:userRegion animated:YES];
    
}

@end
