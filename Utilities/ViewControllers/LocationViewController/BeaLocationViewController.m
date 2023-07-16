#import "BeaLocationViewController.h"

@implementation BeaLocationViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    
    UIEdgeInsets mapInsets = self.mapView.layoutMargins;
    mapInsets.bottom = 30;
    self.mapView.layoutMargins = mapInsets;
    [self.view addSubview:self.mapView];

    self.locationManager = [CLLocationManager performSelector:@selector(sharedManager)];
    self.locationManager.delegate = self;

    self.doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.doneButton.backgroundColor = [UIColor whiteColor];
    self.doneButton.layer.cornerRadius = 8.0;
    self.doneButton.titleLabel.font = [UIFont fontWithName:@"Inter" size:17];
    self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.doneButton];
    
    self.userLocationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.userLocationButton setImage:[UIImage systemImageNamed:@"location"] forState:UIControlStateNormal];
    self.userLocationButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    self.userLocationButton.layer.cornerRadius = 8.0;
    self.userLocationButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.userLocationButton addTarget:self action:@selector(locationButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.userLocationButton];

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.mapView addGestureRecognizer:gestureRecognizer];

    [NSLayoutConstraint activateConstraints:@[
        [self.doneButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [self.doneButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        [self.doneButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10.0],
        [self.doneButton.heightAnchor constraintEqualToConstant:44.0],

        [self.userLocationButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20.0],
        [self.userLocationButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-8.0],
        [self.userLocationButton.widthAnchor constraintEqualToConstant:44.0],
        [self.userLocationButton.heightAnchor constraintEqualToConstant:44.0]
    ]];
}

- (void)setUserLocationEnabledState:(BOOL)arg1 {
    self.userLocationEnabled = arg1;

    // if the user dropped a pin, remove it
    if (self.mapView.annotations.firstObject) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }

    if (self.userLocationEnabled) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.userLocationButton setImage:[UIImage systemImageNamed:@"location.fill"] forState:UIControlStateNormal];
        }];
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            [self.userLocationButton setImage:[UIImage systemImageNamed:@"location"] forState:UIControlStateNormal];
        }];
        [self.locationManager stopUpdatingLocation];
        self.mapView.showsUserLocation = NO;

        self.longitude = 0.0;
        self.latitude = 0.0;
    }
}

- (void)locationButtonTapped {
    [self setUserLocationEnabledState:!self.userLocationEnabled];
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.userLocationEnabled) [self setUserLocationEnabledState:NO];

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = coordinate;
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotation:annotation];
        
        self.latitude = coordinate.latitude;
        self.longitude = coordinate.longitude;
    }
}

- (void)doneButtonTapped {
    if ([self.delegate respondsToSelector:@selector(locationViewController:didSelectLocationWithLatitude:longitude:)]) {
        [self.delegate locationViewController:self didSelectLocationWithLatitude:self.latitude longitude:self.longitude];
    }
    [self.locationManager stopUpdatingLocation];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    self.longitude = location.coordinate.longitude;
    self.latitude = location.coordinate.latitude;
}

#pragma mark - MKMapViewDelegate

// update the maps view when user location updated
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000);
    [mapView setRegion:region animated:YES];
}
@end