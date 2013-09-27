#import "FDRadialMenuItem.h"
#import "FDRadialMenuDelegate.h"


#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface FDRadialMenu : UIView


#pragma mark - Properties

@property (nonatomic, assign) id<FDRadialMenuDelegate> delegate;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *highlightedBackgroundImage;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImage *highlightedIconImage;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, assign) CGFloat desiredRadius;
@property (nonatomic, assign) BOOL moveable;


#pragma mark - Constructors

- (id)initWithBackgroundImage: (UIImage *)backgroundImage 
	highlightedBackgroundImage: (UIImage *)highlightedBackgroundImage 
	iconImage: (UIImage *)iconImage 
	highlightedIconImage: (UIImage *)highlightedIconImage;


#pragma mark - Static Methods


#pragma mark - Instance Methods


@end