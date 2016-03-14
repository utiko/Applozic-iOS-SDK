//
//  ALMapViewController.m
//  ChatApp
//
//  Created by Devashish on 13/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALMapViewController.h"
#import "ALUserDefaultsHandler.h"
#import "ALApplozicSettings.h"
#import "ALDataNetworkConnection.h"
#import "TSMessage.h"
#import "UIImageView+WebCache.h"
#import "ALMessage.h"

@interface ALMapViewController ()


- (IBAction)sendLocation:(id)sender;

@property (nonatomic, strong) CLGeocoder * geocoder;
@property (nonatomic, strong) CLPlacemark * placemark;
@property (nonatomic, strong) NSString * addressLabel;
@property (nonatomic, strong) NSString * longX;
@property (nonatomic, strong) NSString * lattY;
@end

@implementation ALMapViewController
{
    
}
@synthesize locationManager, region;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager requestWhenInUseAuthorization];
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
    [self.mapKitView setShowsUserLocation:YES];
    [self.mapKitView setDelegate:self];
    self.geocoder = [[CLGeocoder alloc] init];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden: YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    if([ALUserDefaultsHandler isBottomTabBarHidden])
    {
        [self.tabBarController.tabBar setHidden: [ALUserDefaultsHandler isBottomTabBarHidden]];
    }
//    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColourForNavigation]];
    [self.navigationController.navigationBar setTintColor:[ALApplozicSettings getColourForNavigationItem]];
    [self.navigationController.navigationBar setBackgroundColor: [ALApplozicSettings getColourForNavigation]];
    
    if (![ALDataNetworkConnection checkDataNetworkAvailable])
    {
        [TSMessage showNotificationInViewController:self title:@"" subtitle:@"No Internet" type:TSMessageNotificationTypeError duration:1.0 canBeDismissedByUser:NO];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendLocation:(id)sender {
    _sendLocationButton.enabled=YES;
    NSLog(@"location sending .... ");
    
    region = self.mapKitView.region;
    
    
    
    NSLog(@"latitude: %.8f && longitude: %.8f", region.center.latitude, region.center.longitude);
    
    //static map location
    NSString * staticMapLocationURL=[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%.8f,%.8f&zoom=17&size=290x179&maptype=roadmap&format=png&visual_refresh=true&markers=%.8f,%.8f",region.center.latitude, region.center.longitude,region.center.latitude, region.center.longitude];
    NSURL* staticImageURL=[NSURL URLWithString:staticMapLocationURL];
    [self.mapView sd_setImageWithURL:staticImageURL];
    
    
    
    
    //simpe location link       comgooglemaps://?q=Pizza&center=37.759748,-122.427135
    
    //    NSString * locationURL=[NSString stringWithFormat:@"http://maps.google.com/?ll=%.8f,%.8f,15z", region.center.latitude, region.center.longitude];
    //   https://www.google.co.in/maps/@12.9328581,77.6274083,19z
    
    //     NSString * locationURL=[NSString stringWithFormat:@"https://www.google.co.in/maps/@%.8f,%.8f,15z&markers=%.8f,%.8f", region.center.latitude, region.center.longitude,region.center.latitude, region.center.longitude];
    
    NSString * locationURL=[NSString stringWithFormat:@"http://maps.google.com/?center=%.8f,%.8f,15z",[self.lattY doubleValue], [self.longX doubleValue]];
    
    if([ALDataNetworkConnection checkDataNetworkAvailable])
    {
        //        locationURL = [self.addressLabel stringByAppendingString:locationURL];
    }
    //    [self.controllerDelegate getUserCurrentLocation:locationURL];
    
    [self.controllerDelegate googleImage:nil withURL:staticMapLocationURL];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //    NSLog(@"%@",[locations lastObject]);
    
//    _sendLocationButton.enabled=NO;
    CLLocation *newLocation = [locations lastObject];
    
    
    self.lattY = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    self.longX = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    
    [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error == nil && [placemarks count] > 0)
        {
//            _sendLocationButton.enabled=YES;
            self.placemark = [placemarks lastObject];
            self.addressLabel = [NSString stringWithFormat:@"Address: %@\n%@ %@, %@, %@\n",
                                 self.placemark.thoroughfare,
                                 self.placemark.postalCode, self.placemark.locality,
                                 self.placemark.administrativeArea,
                                 self.placemark.country];
            
        }
        else
        {
            NSLog(@"inside GEOCODER");
        }
        
    }];
    
}

#pragma mark - MKMapViewDelegate Methods

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    [self.mapKitView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.002f, 0.002f)) animated:YES];
    
}


@end
