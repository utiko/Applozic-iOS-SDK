//
//  ALMapViewController.m
//  ChatApp
//
//  Created by Devashish on 13/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALMapViewController.h"
#import "ALUserDefaultsHandler.h"

@interface ALMapViewController ()


- (IBAction)sendLocation:(id)sender;
@end

@implementation ALMapViewController
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
    
    region = self.mapKitView.region;

    [self.locationManager startUpdatingLocation];

    [self.mapKitView setShowsUserLocation:YES];
    [self.mapKitView setDelegate:self];
    
  
}

-(void)viewWillDisappear:(BOOL)animated{
[self.tabBarController.tabBar setHidden: YES];
}

-(void)viewWillAppear:(BOOL)animated{
[self.tabBarController.tabBar setHidden: YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendLocation:(id)sender {
    NSLog(@"location sending .... ");
    
   
    NSLog(@"latitude: %.8f && longitude: %.8f", region.center.latitude, region.center.longitude);
    
    //static map location
    
    
 /*  NSString * locationURL=[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%.8f,%.8f&zoom=17&size=290x179&maptype=roadmap&format=png&visual_refresh=true&markers=%.8f,%.8f",region.center.latitude, region.center.longitude,region.center.latitude, region.center.longitude];
    */
    
            //simpe location link
     
    NSString * locationURL=[NSString stringWithFormat:@"http://maps.google.com/?ll=%.8f,%.8f,15z", region.center.latitude, region.center.longitude];
   
    
    [self.controllerDelegate getUserCurrentLocation:locationURL];
    
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
    NSLog(@"%@",[locations lastObject]);
    
}


#pragma mark - MKMapViewDelegate Methods

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    [self.mapKitView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.002f, 0.002f)) animated:YES];
    
}


@end
