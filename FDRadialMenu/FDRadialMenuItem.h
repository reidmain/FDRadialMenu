#pragma mark Class Interface

@interface FDRadialMenuItem : NSObject


#pragma mark - Properties

@property (nonatomic, readonly) UIImage *backgroundImage;
@property (nonatomic, readonly) UIImage *highlightedBackgroundImage;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImage *highlightedIconImage;
@property (nonatomic, strong) id context;


#pragma mark - Constructors

- (id)initWithBackgroundImage: (UIImage *)backgroundImage 
	highlightedBackgroundImage: (UIImage *)highlightedBackgroundImage 
	iconImage: (UIImage *)iconImage 
	highlightedIconImage: (UIImage *)highlightedIconImage;


@end