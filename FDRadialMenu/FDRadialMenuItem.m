#import "FDRadialMenuItem.h"
#import "UIView+Layout.h"


#pragma mark Class Extension

@interface FDRadialMenuItem ()

- (void)_buttonPressed;

@end


#pragma mark - Class Definition

@implementation FDRadialMenuItem
{
	@private __strong UIButton *_button;
    @private __weak id _target;
    @private SEL _action;
}


#pragma mark - Properties

- (UIImage *)backgroundImage
{
	UIImage *backgroundImage = [_button backgroundImageForState: UIControlStateNormal];
	
	return backgroundImage;
}

- (UIImage *)highlightedBackgroundImage
{
	UIImage *highlightedBackgroundImage = [_button backgroundImageForState: UIControlStateHighlighted];
	
	return highlightedBackgroundImage;
}

- (UIImage *)iconImage
{
	UIImage *iconImage = [_button imageForState: UIControlStateNormal];
	
	return iconImage;
}
- (void)setIconImage: (UIImage *)iconImage
{
	[_button setImage: iconImage 
		forState: UIControlStateNormal];
}

- (UIImage *)highlightedIconImage
{
	UIImage *highlightedIconImage = [_button imageForState: UIControlStateHighlighted];
	
	return highlightedIconImage;
}
- (void)setHighlightedIconImage: (UIImage *)highlightedIconImage
{
	[_button setImage: highlightedIconImage 
		forState: UIControlStateHighlighted];
}


#pragma mark - Constructors

- (id)initWithBackgroundImage: (UIImage *)backgroundImage 
	highlightedBackgroundImage: (UIImage *)highlightedBackgroundImage 
	iconImage:	(UIImage *)iconImage 
	highlightedIconImage: (UIImage *)highlightedIconImage
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_button = [UIButton buttonWithType: UIButtonTypeCustom];
	_button.width = backgroundImage.size.width;
	_button.height = backgroundImage.size.height;
	
	[_button setBackgroundImage: backgroundImage 
		forState: UIControlStateNormal];
	[_button setBackgroundImage: highlightedBackgroundImage 
		forState: UIControlStateHighlighted];
	[_button setImage: iconImage 
		forState: UIControlStateNormal];
	[_button setImage: highlightedIconImage 
		forState: UIControlStateHighlighted];
	
	[_button addTarget: self 
		action: @selector(_buttonPressed) 
		forControlEvents: UIControlEventTouchUpInside];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Private Methods

- (UIView *)_view
{
	return _button;
}

- (void)_setTarget: (id)target 
	action: (SEL)action
{
	_target = target;
	_action = action;
}

- (void)_buttonPressed
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[_target performSelector: _action 
		withObject: self];
#pragma clang diagnostic pop
}


@end