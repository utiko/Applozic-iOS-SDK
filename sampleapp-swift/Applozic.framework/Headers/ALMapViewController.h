//
//  ALMapViewController.h
//  ChatApp
//
//  Created by Devashish on 13/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol ALMapViewControllerDelegate <NSObject>

-(void) getUserCurrentLocation:(NSString *)googleMapUrl ;

@end
@interface ALMapViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *sendLocationButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapKitView;
@property (strong, nonatomic ) CLLocationManager *locationManager;
@property  MKCoordinateRegion region;

@property(nonatomic, weak) id<ALMapViewControllerDelegate>controllerDelegate;

@end
