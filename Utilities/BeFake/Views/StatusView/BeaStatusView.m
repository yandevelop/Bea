#import "BeaStatusView.h"

@implementation BeaStatusView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0.0;

        self.layer.cornerRadius = 8.0;
        self.layer.masksToBounds = YES;

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = [UIFont fontWithName:@"Inter" size:20.0];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];

        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.messageLabel.font = [UIFont fontWithName:@"Inter" size:11.0];
        self.messageLabel.numberOfLines = 2;
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.messageLabel];
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;

        self.image = [UIImage systemImageNamed:@"exclamationmark.triangle"];
        self.imageView = [[UIImageView alloc] initWithImage:self.image];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.tintColor = [UIColor whiteColor];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.imageView];
        
        [NSLayoutConstraint activateConstraints:@[
            [self.heightAnchor constraintEqualToConstant:64.0],

            [self.titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:66],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8],
            [self.titleLabel.heightAnchor constraintEqualToConstant:24],
            
            [self.messageLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:-2],
            [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:66],
            [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8],
            [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8],
            
            [self.imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12.0],
            [self.imageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:-2],
            [self.imageView.widthAnchor constraintEqualToConstant:38.0],
            [self.imageView.heightAnchor constraintEqualToConstant:38.0]
        ]];
    }
    return self;
}
@end