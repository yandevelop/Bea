#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol BeaLocationViewControllerDelegate;

@interface BeaLocationViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, weak) id<BeaLocationViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *userLocationButton;
@property (nonatomic, assign) BOOL userLocationEnabled;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@protocol BeaLocationViewControllerDelegate <NSObject>
- (void)locationViewController:(BeaLocationViewController *)viewController didSelectLocationWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
@end