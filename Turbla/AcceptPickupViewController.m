//
//  AcceptPickupViewController.m
//  Turbla
//
//  Created by Patricia S Demorest on 11/8/15.
//  Copyright © 2015 Turbla. All rights reserved.
//

#import "AcceptPickupViewController.h"
#import "TimerView.h"
#import "MapPin.h"
#import "EnRouteViewController.h"
#import <AddressBook/AddressBook.h>

@import MapKit;

@interface AcceptPickupViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userCurrentLocation;
@property (nonatomic) NSString *pickUpInfoString;
@property (nonatomic) CLLocationCoordinate2D pickUpCoordinate;
@property (nonatomic) NSTimer *updateTimer;
// TODO: make sure to reset seconds left
@property (nonatomic) CGFloat secondsLeft;


@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) MKMapItem *sourceItem;
@property (nonatomic) MKMapItem *destinationItem;
@property (nonatomic) IBOutlet UILabel *noAvailablePickUpsLabel;

// layered views when pick up is available
@property (nonatomic) IBOutlet UIView *greyShield;
@property (nonatomic) IBOutlet UILabel *pickUpAddressLabel;
@property (nonatomic) IBOutlet TimerView *timerView;
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
    self.pickUpInfoString = NSLocalizedString(@"Pick up available at Rebecca Minkoff -  7 items", nil);
    self.pickUpCoordinate = CLLocationCoordinate2DMake(37.7894888, -122.4338306);
    
}

#pragma mark - Set up
- (void)setUserCurrentLocation:(CLLocationCoordinate2D)userCurrentLocation {
    _userCurrentLocation = userCurrentLocation;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
                      [self displayNewPickUp];
                  });
}

- (void)setUpPrettyViews {
    
    self.noAvailablePickUpsLabel.layer.cornerRadius = 3.0f;
    self.acceptPickUpButton.layer.cornerRadius = 5.0f;
    // PSD TODO: make button alpha 1
    
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
    [self.locationManager requestLocation];
    
}

#pragma mark - New pick up

- (void)displayNewPickUp {
    
    CLLocationCoordinate2D centerRegion = CLLocationCoordinate2DMake(self.pickUpCoordinate.latitude - 0.002, self.pickUpCoordinate.longitude);
    MKCoordinateRegion pickUpRegion = MKCoordinateRegionMake(centerRegion, MKCoordinateSpanMake(0.02, 0.02));
    [self.mapView setRegion:pickUpRegion animated:YES];
    
    // add request for ETA
    [self makeETARequest];
    
    self.noAvailablePickUpsLabel.hidden = YES;
    self.pickUpAddressLabel.text = self.pickUpInfoString;
    
    [self.view addSubview:self.greyShield];
    self.greyShield.translatesAutoresizingMaskIntoConstraints = NO;
    
    // add the constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.greyShield attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.greyShield attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.greyShield attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.33f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.greyShield attribute:NSLayoutAttributeBottom multiplier:1.0f constant:49.0f]];
    
    // force the layout to happen before the animation (otherwise drawing views doesn't happen until execution returns to the main event loop)
    [self.view layoutIfNeeded];
    
    // fade in the views
    self.greyShield.alpha = 0.0f;
    [UIView animateWithDuration:0.3f animations:^{
        self.greyShield.alpha = 0.7f;
    }];
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerView:) userInfo:nil repeats:YES];
    self.secondsLeft = 20;
    
}

- (void)makeETARequest {
    
    MKDirectionsRequest *etaRequest = [[MKDirectionsRequest alloc] init];
    self.sourceItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.userCurrentLocation addressDictionary:nil]];
    self.sourceItem.name = @"Current Location";
    self.destinationItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.pickUpCoordinate addressDictionary:nil]];
    self.destinationItem.name = @"Rebecca Minkoff - 2124 Fillmore St, San Francisco, CA 94115";
    [etaRequest setSource:self.sourceItem];
    [etaRequest setDestination:self.destinationItem];
    [etaRequest setTransportType:MKDirectionsTransportTypeAutomobile];
    MKDirections *pickUpDirections = [[MKDirections alloc] initWithRequest:etaRequest];
    [pickUpDirections calculateETAWithCompletionHandler:^(MKETAResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            NSTimeInterval travelTime = response.expectedTravelTime;
            
            NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
            dateComponentsFormatter.unitsStyle = NSDateFormatterShortStyle;
            
            NSString *title = [NSString stringWithFormat:@"Rebecca Minkoff  |  %@",[dateComponentsFormatter stringFromTimeInterval:travelTime]];
            
            // add annotation
            MapPin *pickUpPin = [[MapPin alloc] initWithCoordinate:self.pickUpCoordinate placeName:title description:@"2124 Fillmore St, San Francisco, CA 94115"];
            [self.mapView addAnnotation:pickUpPin];
            [self.mapView selectAnnotation:pickUpPin animated:YES];
            
        } else {
            // PSD TODO: set alert that there was an error
        }
        
    }];
}

- (void)updateTimerView:(NSTimer *)timer {
    
    self.secondsLeft -= 1;
    self.timerView.percent = self.secondsLeft / 20.0f;
    [self.timerView setNeedsDisplay];
    
    if (self.secondsLeft == 0) {
        [self.updateTimer invalidate];
        [self.greyShield removeFromSuperview];
        // TODO: get rid of pick up pin and zoom back out to user's location
    }
}

#pragma mark - CLLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    self.userCurrentLocation = currentLocation.coordinate;
    
    MKCoordinateRegion userRegion = MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(0.2, 0.2));
    [self.mapView setRegion:userRegion animated:YES];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.userCurrentLocation = newLocation.coordinate;
    
    MKCoordinateRegion userRegion = MKCoordinateRegionMake(newLocation.coordinate, MKCoordinateSpanMake(0.2, 0.2));
    [self.mapView setRegion:userRegion animated:YES];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

#pragma mark - IBActions

- (IBAction)acceptPickUpButtonTapped:(id)sender {
    
    NSArray* items = [[NSArray alloc] initWithObjects:self.sourceItem, self.destinationItem, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    if ([MKMapItem respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        [MKMapItem openMapsWithItems:items launchOptions:options];
        // PSD TODO: transition to next contoller
    } else {
        // PSD TODO: handle error
    }
    
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[EnRouteViewController class]]) {
        EnRouteViewController *enRouteViewController = segue.destinationViewController;
        enRouteViewController.destinationAddress = self.pickUpInfoString;
        enRouteViewController.destinationCoordinate = self.pickUpCoordinate;
    }
    
}


@end
