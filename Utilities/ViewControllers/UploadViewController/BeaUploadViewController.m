#import "BeaUploadViewController.h"
#import <objc/runtime.h>

@implementation BeaUploadViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationVC = [[BeaLocationViewController alloc] init];
        self.locationVC.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    #ifdef JAILED
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Bea" ofType:@"bundle"];
		NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
		UIImage *beFakeLogo = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"BeFake" ofType:@"png"]];
	#else
		NSBundle *bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/Bea.bundle")];
		UIImage *beFakeLogo = [UIImage imageNamed:@"BeFake.png" inBundle:bundle compatibleWithTraitCollection:nil];
	#endif


    self.view.backgroundColor = [UIColor blackColor];
    self.spotifyViewController = [[BeaSpotifyViewController alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicManagerDidUpdateMusic) name:@"MusicUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMusicViewController) name:@"openSpotifyViewController" object:nil];

    self.titleImageView = [[UIImageView alloc] initWithImage:beFakeLogo];
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.titleImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleImageView];

    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];

    UIImage *backButtonImage = [[UIImage systemImageNamed:@"chevron.down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.backButtonImageView = [[UIImageView alloc] initWithImage:backButtonImage];
    self.backButtonImageView.tintColor = [UIColor whiteColor];
    self.backButtonImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton addSubview:self.backButtonImageView];

    self.statusView = [[BeaStatusView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.statusView];
    self.statusView.translatesAutoresizingMaskIntoConstraints = NO;

    self.frontImageView = [[UIImageView alloc] init];
    self.frontImageView.backgroundColor = [UIColor blackColor];
    self.frontImageView.layer.borderWidth = 1.8;
    self.frontImageView.layer.cornerRadius = 8.0;
    self.frontImageView.layer.masksToBounds = YES;
    self.frontImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.frontImageView.userInteractionEnabled = YES;
    self.frontImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.frontImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UITapGestureRecognizer *frontTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    [self.frontImageView addGestureRecognizer:frontTapRecognizer];

    [self.view addSubview:self.frontImageView];

    self.frontTextLabel = [[UILabel alloc] init];
    self.frontTextLabel.font = [UIFont fontWithName:@"Inter" size:14];
    self.frontTextLabel.text = @"Front image";
    self.frontTextLabel.textAlignment = NSTextAlignmentCenter;
    self.frontTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.frontImageView addSubview:self.frontTextLabel];

    self.backImageView = [[UIImageView alloc] init];
    self.backImageView.backgroundColor = [UIColor blackColor];
    self.backImageView.layer.borderWidth = 1.8;
    self.backImageView.layer.cornerRadius = 8.0;
    self.backImageView.layer.masksToBounds = YES;
    self.backImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.backImageView.userInteractionEnabled = YES;
    self.backImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UITapGestureRecognizer *backTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    [self.backImageView addGestureRecognizer:backTapRecognizer];
    [self.view addSubview:self.backImageView];

    self.backTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.backTextLabel.font = [UIFont fontWithName:@"Inter" size:14];
    self.backTextLabel.text = @"Back image";
    self.backTextLabel.textAlignment = NSTextAlignmentCenter;
    self.backTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backImageView addSubview:self.backTextLabel];

    self.captionTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.captionTextField.placeholder = @"Caption";
    self.captionTextField.font = [UIFont fontWithName:@"Inter" size:13];
    self.captionTextField.backgroundColor = [UIColor blackColor];
    self.captionTextField.layer.cornerRadius = 8.0;
    self.captionTextField.layer.borderWidth = 1.2;
    self.captionTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.captionTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.captionTextField.delegate = self;

    self.captionTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    self.captionTextField.leftViewMode = UITextFieldViewModeAlways;

    [self.captionTextField addTarget:self action:@selector(captionTextFieldDidChange:) forControlEvents:UIControlEventEditingDidEnd];
    [self.view addSubview: self.captionTextField];

    self.retakeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.retakeTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.retakeTextField.placeholder = @"Retakes";
    self.retakeTextField.font = [UIFont fontWithName:@"Inter" size:13];
    self.retakeTextField.backgroundColor = [UIColor blackColor];
    self.retakeTextField.layer.cornerRadius = 8.0;
    self.retakeTextField.layer.borderWidth = 1.2;
    self.retakeTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.retakeTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.retakeTextField.delegate = self;

    self.retakeTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    self.retakeTextField.leftViewMode = UITextFieldViewModeAlways;

    [self.retakeTextField addTarget:self action:@selector(retakeTextFieldDidChange:) forControlEvents:UIControlEventEditingDidEnd];
    [self.view addSubview: self.retakeTextField];

    self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[self.actionButton setTitle:@"Send" forState:UIControlStateNormal];
	[self.actionButton addTarget:self action:@selector(sendBeReal) forControlEvents:UIControlEventTouchUpInside];
	[self.actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	self.actionButton.backgroundColor = [UIColor whiteColor];
	self.actionButton.titleLabel.font = [UIFont fontWithName:@"Inter" size:17];
	self.actionButton.layer.cornerRadius = 8.0;
    self.actionButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:self.actionButton];

    self.locationLabel = [[UILabel alloc] init];
    self.locationLabel.font = [UIFont fontWithName:@"Inter" size:22];
    self.locationLabel.text = @"Location";
    self.locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.locationLabel];

    self.locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.locationButton.frame = CGRectMake(0, 0, 32, 32);
    self.locationButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.locationButton addTarget:self action:@selector(locationButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.locationButton];

    UIImage *image = [[UIImage systemImageNamed:@"mappin.circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tintColor = [UIColor whiteColor];
    imageView.frame = self.locationButton.bounds;
    [self.locationButton addSubview:imageView];

    self.isLateSwitch = [[UISwitch alloc] init];
    self.isLateSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.isLateSwitch addTarget:self action:@selector(isLateStateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.isLateSwitch setOn:NO animated:NO];
    [self.view addSubview:self.isLateSwitch];

    self.isLateLabel = [[UILabel alloc] init];
    self.isLateLabel.font = [UIFont fontWithName:@"Inter" size:22];
    self.isLateLabel.text = @"Post late";
    self.isLateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.isLateLabel];

    self.spotifyMusicView = [[BeaSpotifyMusicView alloc] init];
    [self.view addSubview:self.spotifyMusicView];

    self.dropdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dropdownButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.dropdownButton];

    UIImage *dotImage = [[UIImage systemImageNamed:@"ellipsis"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.dropdownImageView = [[UIImageView alloc] initWithImage:dotImage];
    self.dropdownImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dropdownImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.dropdownImageView setTintColor:[UIColor whiteColor]];
    [self.dropdownButton addSubview:self.dropdownImageView];

    NSMutableArray *actions = [[NSMutableArray alloc] init];
    [actions addObject:[UIAction actionWithTitle:@"Show Information" image:[UIImage systemImageNamed:@"info.circle.fill"] identifier:nil handler:^(UIAction * action) {
        BeaInfoViewController *infoViewController = [[BeaInfoViewController alloc] init];
        [self presentViewController:infoViewController animated:YES completion:nil];
	}]];

    NSString *donationImage;
    if (@available(iOS 16.0, *)) {
        donationImage = @"mug.fill";
    } else {
        donationImage = @"dollarsign.circle.fill";
    }

    [actions addObject:[UIAction actionWithTitle:@"Buy me a ☕" image:[UIImage systemImageNamed:donationImage] identifier:nil handler:^(UIAction * action) {
		NSURL *kofiURL = [NSURL URLWithString:@"https://ko-fi.com/yandevelop"];
        if ([[UIApplication sharedApplication] canOpenURL:kofiURL]) {
            [[UIApplication sharedApplication] openURL:kofiURL options:@{} completionHandler:nil];
        }
	}]];

    UIMenu *menu = [UIMenu menuWithChildren:actions];
    [self.dropdownButton setShowsMenuAsPrimaryAction:true];
    [self.dropdownButton setMenu:menu];

    [NSLayoutConstraint activateConstraints:@[
        [self.frontImageView.centerXAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:2 + self.view.frame.size.width / 4],
        [self.frontImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:110],
        [self.frontImageView.widthAnchor constraintEqualToConstant:150],
        [self.frontImageView.heightAnchor constraintEqualToConstant:200],
        [self.frontTextLabel.centerXAnchor constraintEqualToAnchor:self.frontImageView.centerXAnchor],
        [self.frontTextLabel.centerYAnchor constraintEqualToAnchor:self.frontImageView.centerYAnchor],

        [self.backImageView.centerXAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-2 - self.view.frame.size.width / 4],
		[self.backImageView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:110],
		[self.backImageView.widthAnchor constraintEqualToConstant:150],
		[self.backImageView.heightAnchor constraintEqualToConstant:200],
        [self.backTextLabel.centerXAnchor constraintEqualToAnchor:self.backImageView.centerXAnchor],
        [self.backTextLabel.centerYAnchor constraintEqualToAnchor:self.backImageView.centerYAnchor],

        [self.captionTextField.topAnchor constraintEqualToAnchor:self.frontImageView.bottomAnchor constant:20],
        [self.captionTextField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:22],
        [self.captionTextField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-22],
        [self.captionTextField.heightAnchor constraintEqualToConstant:40],

        [self.retakeTextField.topAnchor constraintEqualToAnchor:self.captionTextField.bottomAnchor constant:20],
        [self.retakeTextField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:22],
        [self.retakeTextField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-22],
        [self.retakeTextField.heightAnchor constraintEqualToConstant:40],

        [self.isLateSwitch.topAnchor constraintEqualToAnchor:self.retakeTextField.bottomAnchor constant:30],
        [self.isLateSwitch.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-22],

        [self.isLateLabel.centerYAnchor constraintEqualToAnchor:self.isLateSwitch.centerYAnchor],
        [self.isLateLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:22],

        [self.locationButton.topAnchor constraintEqualToAnchor:self.isLateSwitch.bottomAnchor constant:20],
        [self.locationButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-22],
        [self.locationButton.widthAnchor constraintEqualToConstant:32],
        [self.locationButton.heightAnchor constraintEqualToAnchor:self.locationButton.widthAnchor],

        [self.locationLabel.centerYAnchor constraintEqualToAnchor:self.locationButton.centerYAnchor],
        [self.locationLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:22],
        [self.locationLabel.trailingAnchor constraintEqualToAnchor:self.locationButton.leadingAnchor],

        [self.actionButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.actionButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.actionButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [self.actionButton.heightAnchor constraintEqualToConstant:44],

        [self.statusView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.statusView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.statusView.bottomAnchor constraintEqualToAnchor:self.actionButton.topAnchor constant: -20],

        [self.titleImageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [self.titleImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.titleImageView.heightAnchor constraintEqualToConstant:18],
        [self.titleImageView.widthAnchor constraintEqualToConstant:84],

        [self.backButton.centerYAnchor constraintEqualToAnchor:self.titleImageView.centerYAnchor],
        [self.backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.backButton.widthAnchor constraintEqualToConstant:40],
        [self.backButton.heightAnchor constraintEqualToConstant:40],

        [self.backButtonImageView.centerYAnchor constraintEqualToAnchor:self.backButton.centerYAnchor],
        [self.backButtonImageView.widthAnchor constraintEqualToConstant:20],
        [self.backButtonImageView.heightAnchor constraintEqualToConstant:20],

        [self.dropdownButton.centerYAnchor constraintEqualToAnchor:self.titleImageView.centerYAnchor],
        [self.dropdownButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.dropdownButton.widthAnchor constraintEqualToConstant:40],
        [self.dropdownButton.heightAnchor constraintEqualToConstant:40],

        [self.dropdownImageView.trailingAnchor constraintEqualToAnchor:self.dropdownButton.trailingAnchor],
        [self.dropdownImageView.centerYAnchor constraintEqualToAnchor:self.dropdownButton.centerYAnchor],
        [self.dropdownImageView.widthAnchor constraintEqualToAnchor:self.dropdownButton.widthAnchor multiplier:0.57],
        [self.dropdownImageView.heightAnchor constraintEqualToAnchor:self.dropdownButton.heightAnchor multiplier:0.57],

        [self.spotifyMusicView.topAnchor constraintEqualToAnchor:self.locationButton.bottomAnchor constant:14],
        [self.spotifyMusicView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.spotifyMusicView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.spotifyMusicView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.spotifyMusicView.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor constant:-44],
        [self.spotifyMusicView.heightAnchor constraintEqualToConstant:46],
    ]];

    [self checkForLatestVersion];
}

- (void)showMusicViewController {
    [self presentViewController:self.spotifyViewController animated:YES completion:nil];
}

- (void)musicManagerDidUpdateMusic {
    if ([BeaMusicManager sharedInstance].playingStatus == 0) {
        self.musicDict = nil;
        return;
    }

    self.musicDict = [[BeaMusicManager sharedInstance] musicDict];
}

- (void)checkForLatestVersion {
    NSString *currentVersion = TWEAK_VERSION;
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/repos/yandevelop/Bea/releases/latest"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *latestVersion = json[@"tag_name"];
        
            if ([currentVersion compare:latestVersion options:NSNumericSearch] == NSOrderedAscending) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Update Available" message:@"A new version of Bea is available.\nDo you want to update now?" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSURL *githubURL = [NSURL URLWithString:@"https://github.com/yandevelop/Bea/releases/latest"];
                        if ([[UIApplication sharedApplication] canOpenURL:githubURL]) {
                            [[UIApplication sharedApplication] openURL:githubURL options:@{} completionHandler:nil];
                        }
                    }]];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:alertController animated:YES completion:nil];
                });
            }
        }
    }];
    [dataTask resume];
}

- (void)isLateStateChanged:(UISwitch *)sender {
    if (sender.isOn) {
        self.isLate = YES;
    } else {
        self.isLate = NO;
    }
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationButtonTapped {
    [self presentViewController:self.locationVC animated:YES completion:nil];
}

- (void)locationViewController:(BeaLocationViewController *)viewController didSelectLocationWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    self.latitude = latitude;
    self.longitude = longitude;

    if (latitude == 0.0 && longitude == 0.0) {
        self.locationLabel.text = @"Location";
        return;
    }

    self.locationLabel.text = @"Loading...";

    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            self.locationLabel.text = @"An error occured";
            return;
        }
        
        if (placemarks.count > 0) {
            CLPlacemark *placemark = placemarks.firstObject;
            if (placemark.locality && placemark.country) {
                self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.ISOcountryCode];   
                return;
            }
        }
        self.locationLabel.text = @"City not found";
    }];
}

- (void)showErrorWithTitle:(NSString *)title message:(NSString *)message {
    self.statusView.titleLabel.text = title;
    self.statusView.messageLabel.text = message;
    self.statusView.backgroundColor = [UIColor colorWithRed: 0.95 green: 0.15 blue: 0.07 alpha: 1.00];
    self.statusView.imageView.image = self.statusView.image;

    [UIView animateWithDuration:0.3 animations:^{
        self.statusView.alpha = 1.0;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.statusView.alpha = 0.0;
        }];
    });
}

- (void)imageViewTapped:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        UIImageView *tapped = (UIImageView *)gestureRecognizer.view;
        if (tapped == self.frontImageView) {
            imagePicker.view.tag = 1;
        } else if (tapped == self.backImageView) {
            imagePicker.view.tag = 2;
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose an Image Source" message:@"Select the desired image source for your content." preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Open Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            if (tapped == self.frontImageView) {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            } else {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            }
            [self presentViewController:imagePicker animated:YES completion:nil];
        }];

        UIImage *cameraImage = [UIImage systemImageNamed:@"camera" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:19]];
        [cameraAction setValue:cameraImage forKey:@"image"];
        
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"Choose from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }];

        UIImage *photoImage = [UIImage systemImageNamed:@"photo" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:19]];
        [photoAction setValue:photoImage forKey:@"image"];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:cameraAction];
        [alertController addAction:photoAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];

    // check if the source type is camera or photo library and then check
    // if the picked photo is for the front image or back image view and assign it to it
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (picker.view.tag == 1) {
            UIImage *mirrored = [UIImage imageWithCGImage:pickedImage.CGImage scale:pickedImage.scale orientation:UIImageOrientationLeftMirrored];
            self.frontImage = mirrored;
            self.frontImageView.image = self.frontImage;
        } else if (picker.view.tag == 2) {
            self.backImage = pickedImage;
            self.backImageView.image = self.backImage;
        }
    } else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        if (picker.view.tag == 1) {
            self.frontImage = pickedImage;
            self.frontImageView.image = self.frontImage;
        } else if (picker.view.tag == 2) {
            self.backImage = pickedImage;
            self.backImageView.image = self.backImage;
        }
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

// methods for the text field
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// method for the caption text field
- (void)captionTextFieldDidChange:(UITextField *)textField {
    self.caption = textField.text;
}

// method for the retake text field
- (void)retakeTextFieldDidChange:(UITextField *)textField {
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    BOOL containsNonDigits = [textField.text rangeOfCharacterFromSet:nonDigits].location != NSNotFound;
    
    if (!containsNonDigits) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        NSNumber *number = [numberFormatter numberFromString:textField.text];
        self.retakeCount = number;
        textField.layer.borderColor = [UIColor whiteColor].CGColor;
    } else {
        textField.layer.borderColor = [UIColor redColor].CGColor;
        CALayer *layer = textField.layer;
    
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.3;
        animation.repeatCount = 1;
        animation.values = @[
            [NSValue valueWithCGPoint:CGPointMake(layer.position.x - 10, layer.position.y)],
            [NSValue valueWithCGPoint:CGPointMake(layer.position.x + 10, layer.position.y)],
            [NSValue valueWithCGPoint:CGPointMake(layer.position.x - 10, layer.position.y)],
            [NSValue valueWithCGPoint:CGPointMake(layer.position.x + 10, layer.position.y)],
            [NSValue valueWithCGPoint:CGPointMake(layer.position.x, layer.position.y)]
        ];

        [layer addAnimation:animation forKey:@"shake"];
    }
}

- (void)sendBeReal {
    if (!self.frontImage || !self.backImage) {
        [self showErrorWithTitle:@"Missing images" message:@"Select all required images."];
        return;    
    }

    self.actionButton.enabled = NO;
    [self.actionButton setTitle:@"" forState:UIControlStateNormal];

    // stop the api calls being made
    [self.spotifyMusicView stopTimer];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    spinner.center = self.actionButton.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];

    [UIView animateWithDuration:0.3 animations:^{
        self.actionButton.alpha = 0.5;
    }];

    // if the access token is not available, return
    if (![[BeaTokenManager sharedInstance] BRAccessToken]) {
        [self showErrorWithTitle:@"Something went wrong" message:@"2 - Please restart the app and try again."];
        return;
    }

    NSDictionary *userData = [self createDataDictionary];

    // because of processing the images the spinner lags a bit
    BeaUploadTask *task = [[BeaUploadTask alloc] initWithData:userData frontImage:self.frontImage backImage:self.backImage];
    [task uploadBeRealWithCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            self.actionButton.enabled = YES;
            [self.actionButton setTitle:@"Send" forState:UIControlStateNormal];
            [UIView animateWithDuration:0.3 animations:^{
                self.actionButton.alpha = 1.0;
            }];
            
            if (success) {
                [self uploadDidSucceed];
            } else {
                [self showErrorWithTitle:error.userInfo[@"title"] message:error.userInfo[@"description"]];
            }
        });
    }];
}

- (void)uploadDidSucceed {
    self.statusView.backgroundColor = [UIColor colorWithRed:76.0/255.0 green:178.0/255.0 blue:80.0/255.0 alpha:1.0];
    self.statusView.titleLabel.text = @"Success 🎉";
    self.statusView.messageLabel.text = @"Your BeReal was uploaded successfully!";

    UIImage *checkmarkImage = [UIImage systemImageNamed:@"checkmark.circle"];

    self.statusView.imageView.image = checkmarkImage;

    [UIView animateWithDuration:0.3 animations:^{
        self.statusView.alpha = 1.0;
        self.frontTextLabel.alpha = 1.0;
        self.backTextLabel.alpha = 1.0;
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 7 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.statusView.alpha = 0.0;
        }];
    });

    // reset the view and properties to initial state
    self.frontImageView.image = nil;
    self.backImageView.image = nil;
    self.frontImage = nil;
    self.backImage = nil;
    self.caption = nil;
    self.captionTextField.text = nil;
    self.retakeCount = nil;
    self.retakeTextField.text = nil;
    self.longitude = 0.0;
    self.latitude = 0.0;
}

- (NSDictionary *)createDataDictionary {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];

    [data setValue:@(self.isLate) forKey:@"isLate"];
    
    if (self.caption) {
        [data setObject:self.caption forKey:@"caption"];
    }
    if (self.retakeCount) {
        [data setObject:self.retakeCount forKey:@"retakeCounter"];
    }
    if ((self.latitude != 0.0) && (self.longitude != 0.0)) {
        NSNumber *longitudeNumber = @(self.longitude);
        NSNumber *latitudeNumber = @(self.latitude);

        [data setObject:longitudeNumber forKey:@"longitude"];
        [data setObject:latitudeNumber forKey:@"latitude"];
    }

    if (self.musicDict && [BeaMusicManager sharedInstance].playingStatus == 1) {
        [data addEntriesFromDictionary:self.musicDict];
    }

    return [data copy];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MusicUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openSpotifyViewController" object:nil];
    [self.spotifyMusicView stopTimer];
    [[BeaMusicManager sharedInstance] resetData];
}
@end