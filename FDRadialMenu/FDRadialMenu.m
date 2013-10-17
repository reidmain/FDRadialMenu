#import "FDRadialMenu.h"
#import "FDRadialMenuItem+Private.h"
#import "UIView+Layout.h"
#import "FDDegreesToRadians.h"
#import "FDCircleView.h"


#pragma mark Constants

#define DEBUG_DRAWINGS 0 // Set to 1 to draw circles showing the intersection points with the view's bounds.


#pragma mark - Class Extension

@interface FDRadialMenu ()

- (void)_initializeRadialMenu;
- (void)_calculateMinimumRequiredRadius;
- (void)_refreshRadiusAndAngles;
- (void)_openMenu;
- (void)_closeMenu;
- (void)_toggleMenu;
- (void)_radialMenuItemPressed: (FDRadialMenuItem *)radialMenuItem;
- (void)_setupDynamicAnimator;
- (void)_handlePanGestureRecognized: (UIPanGestureRecognizer *)panGestureRecognizer;

@end


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation FDRadialMenu
{
	@private __strong UIButton *_button;
	@private CGFloat _halfMaximumMenuItemDimension;
	@private CGFloat _radius;
	@private CGFloat _startingAngle;
	@private CGFloat _populatedAngle;
	@private CGFloat _itemSpacing;
	@private BOOL _menuOpen;
	@private __weak UIPanGestureRecognizer *_panGestureRecognizer;
	@private __strong UIDynamicAnimator *_dynamicAnimator;
	@private __strong UIAttachmentBehavior *_attachmentBehavior;
	@private __strong UIDynamicItemBehavior *_dynamicItemBehavior;
	@private __strong UICollisionBehavior *_collisionBehavior;
#if DEBUG_DRAWINGS
	@private __strong UIView *_outlineView;
	@private __strong FDCircleView *_outlineCircle;
	@private __strong FDCircleView *_desiredRadiusCircle;
#endif
}


#pragma mark - Properties

- (UIImage *)backgroundImage
{
	UIImage *backgroundImage = [_button backgroundImageForState: UIControlStateNormal];
	
	return backgroundImage;
}
- (void)setBackgroundImage: (UIImage *)backgroundImage
{
	[_button setBackgroundImage: backgroundImage 
		forState: UIControlStateNormal];
}

- (UIImage *)highlightedBackgroundImage
{
	UIImage *highlightedBackgroundImage = [_button backgroundImageForState: UIControlStateHighlighted];
	
	return highlightedBackgroundImage;
}
- (void)setHighlightedBackgroundImage: (UIImage *)highlightedBackgroundImage
{
	[_button setBackgroundImage: highlightedBackgroundImage 
		forState: UIControlStateHighlighted];
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

- (void)setItems: (NSArray *)items
{
	if (_items != items)
	{
		_items = [items copy];
		
		// Calculate half of the maximum dimension of the menu items to ensure that there is a margin on all sides of the super view so no menu items are clipped.
		[_items enumerateObjectsUsingBlock: ^(FDRadialMenuItem *radialMenuItem, NSUInteger idx, BOOL *stop)
			{
				CGSize menuItemSize = [radialMenuItem _view].bounds.size;
				
				_halfMaximumMenuItemDimension = MAX(_halfMaximumMenuItemDimension, MAX(menuItemSize.width, menuItemSize.height));
			}];
		_halfMaximumMenuItemDimension /= 2.0f;
	}
}

- (void)setDesiredRadius: (CGFloat)desiredRadius
{
	if (desiredRadius > 0.0f)
	{
		_desiredRadius = desiredRadius;
	}
}

- (void)setMoveable: (BOOL)moveable
{
	if (_moveable != moveable)
	{
		_moveable = moveable;
		
		if (_moveable == YES 
			&& _panGestureRecognizer == nil)
		{
			// Create a pan gesture recongizer to allow the user to drag the menu around.
			UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] 
				initWithTarget: self 
					action: @selector(_handlePanGestureRecognized:)];
			panGestureRecognizer.maximumNumberOfTouches = 1;
			
			_panGestureRecognizer = panGestureRecognizer;
			
			[self addGestureRecognizer: _panGestureRecognizer];
			
			// Create an attachment behavior that will be used to move the menu item around when the user drags it.
			_attachmentBehavior = [[UIAttachmentBehavior alloc] 
				initWithItem: self 
					attachedToAnchor: CGPointZero];
			
			// Create a dynamic item behavior for the menu so it will not rotate when thrown and not bounce too hard when it collides with its boundaries.
			_dynamicItemBehavior = [[UIDynamicItemBehavior alloc] 
				initWithItems: @[ self ]];
			_dynamicItemBehavior.allowsRotation = NO;
			_dynamicItemBehavior.elasticity = 0.0f;
			_dynamicItemBehavior.resistance = 7.0f;
			_dynamicItemBehavior.friction = 1.0f;
			_dynamicItemBehavior.density = 3.0f;
			
			// Create a collision behavior for the menu that uses the reference view's bounds.
			_collisionBehavior = [[UICollisionBehavior alloc] 
				initWithItems: @[ self ]];
			_collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
			
			[self _setupDynamicAnimator];
		}
		else
		{
			[self removeGestureRecognizer: _panGestureRecognizer];
		}
	}
}


#pragma mark - Constructors

- (id)initWithBackgroundImage: (UIImage *)backgroundImage 
	highlightedBackgroundImage: (UIImage *)highlightedBackgroundImage 
	iconImage:	(UIImage *)iconImage 
	highlightedIconImage: (UIImage *)highlightedIconImage
{
	// Make the radial menu the same size as the background image.
	CGRect frame = CGRectMake(0.0f, 0.0f, backgroundImage.size.width, backgroundImage.size.height);
	
	// Abort if base initializer fails.
	if ((self = [super initWithFrame: frame]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeRadialMenu];
	
	// Set the images of the menu.
	[_button setBackgroundImage: backgroundImage 
		forState: UIControlStateNormal];
	[_button setBackgroundImage: highlightedBackgroundImage 
		forState: UIControlStateHighlighted];
	[_button setImage: iconImage 
		forState: UIControlStateNormal];
	[_button setImage: highlightedIconImage 
		forState: UIControlStateHighlighted];
	
	// Return initialized instance.
	return self;
}

- (id)initWithFrame: (CGRect)frame
{
	// Abort if base initializer fails.
	if ((self = [super initWithFrame: frame]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeRadialMenu];
	
	// Return initialized instance.
	return self;
}

- (id)initWithCoder: (NSCoder *)coder
{
	// Abort if base initializer fails.
	if ((self = [super initWithCoder: coder]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeRadialMenu];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods


#pragma mark - Overridden Methods

- (CGSize)intrinsicContentSize
{
	CGSize intrinsicContentSize = _button.bounds.size;
	
	return intrinsicContentSize;
}

#if DEBUG_DRAWINGS
- (void)layoutSubviews
{
	[self _refreshRadiusAndAngles];
	
	if (_outlineView.superview == nil)
	{
		[self.superview insertSubview: _outlineView 
			belowSubview: self];
	}
	
	if (_desiredRadiusCircle.superview == nil)
	{
		[self.superview insertSubview: _desiredRadiusCircle 
			belowSubview: self];
	}
	
	if (_outlineCircle.superview == nil)
	{
		[self.superview insertSubview: _outlineCircle 
			belowSubview: self];
	}
}
#endif

- (void)didMoveToSuperview
{
	// When the view is added to a superview destroy any existing dynamic animator.
	[_dynamicAnimator removeAllBehaviors];
	_dynamicAnimator = nil;
	
	// If the menu is moveable create a dynamic animator.
	if (_moveable == YES)
	{
		[self _setupDynamicAnimator];
	}
}


#pragma mark - Private Methods

- (void)_initializeRadialMenu
{
#if DEBUG_DRAWINGS
	// Create a view to display the bounds of the menu items in the super view.
	_outlineView = [[UIView alloc] 
		initWithFrame: CGRectZero];
	_outlineView.userInteractionEnabled = NO;
	_outlineView.backgroundColor = [UIColor clearColor];
	_outlineView.layer.borderColor = [[UIColor blackColor] CGColor];
	_outlineView.layer.borderWidth = 1.0f;
	
	// Create a circle view that will display the points that intersect with the outline view.
	_outlineCircle = [[FDCircleView alloc] 
		initWithFrame: CGRectZero];
	_outlineCircle.strokeColor = [UIColor greenColor];
	
	// Create a circle view to show the actual circle that the menu items will be laid out on.
	_desiredRadiusCircle = [[FDCircleView alloc] 
		initWithFrame: CGRectZero];
	_desiredRadiusCircle.strokeColor = [UIColor redColor];
#endif
	
	_desiredRadius = self.width + 5.0f;
	
	// Create a button that will be used to open/close the menu.
	_button = [UIButton buttonWithType: UIButtonTypeCustom];
	_button.width = self.width;
	_button.height = self.height;
	
	[_button addTarget: self 
		action: @selector(_toggleMenu) 
		forControlEvents: UIControlEventTouchUpInside];
	
	[self addSubview: _button];
}

- (void)_calculateMinimumRequiredRadius
{
	// Calculate if the circle centered around the menu intersects the top or bottom of the superview.
	BOOL intersectsTop = self.center.y - _radius - _halfMaximumMenuItemDimension <= 0.0f;
	BOOL intersectsBottom = self.center.y + _radius + _halfMaximumMenuItemDimension >= self.superview.height;
	
	// Default to using a full circle if it does not intersect any side of the superview.
	_startingAngle = -M_PI;
	_populatedAngle = 2 * M_PI;
	
	// Determine if the circle centered around the menu is intersecting the left side of the view.
	if(self.center.x - _radius - _halfMaximumMenuItemDimension <= 0.0f)
	{
		// Calculate the angle which the circle is intersecting with the left side of the superview. Arccosine can be used because the intersection point of the cicle in the top two quadrants can be mirrored along the y-axis to get the intersection point in the bottom two quadrants.
		CGFloat xDifference = _halfMaximumMenuItemDimension - self.center.x;
		CGFloat leftIntersectionAngle = acosf(xDifference / _radius);
		
		if(intersectsTop == YES)
		{
			// Calculate the angle which the circle is intersecting with the top side of the superview. The circle is also intersecting with the left side of the superview so arcsine can safely be used to calculate the angle because the first and fourth quadrants are the only possible points of intersection.
			CGFloat yDifference = self.center.y - _halfMaximumMenuItemDimension;
			CGFloat topIntersectionAngle = asinf(yDifference / _radius);
			
			_startingAngle = -topIntersectionAngle;
			_populatedAngle = topIntersectionAngle + leftIntersectionAngle;
		}
		else if(intersectsBottom == YES)
		{
			// Calculate the angle which the circle is intersecting with the bottom side of the superview. The circle is also intersecting with the left side of the superview so arcsine can safely be used to calculate the angle because the first and fourth quadrants are the only possible points of intersection.
			CGFloat yDifference = self.superview.height - _halfMaximumMenuItemDimension - self.center.y;
			CGFloat bottomIntersectionAngle = asinf(yDifference / _radius);
			
			_startingAngle = -leftIntersectionAngle;
			_populatedAngle = leftIntersectionAngle + bottomIntersectionAngle;
		}
		else
		{
			_startingAngle = -leftIntersectionAngle;
			_populatedAngle = leftIntersectionAngle + leftIntersectionAngle;
		}
	}
	// Determine if if the circle centered around the menu is intersecting the right side of the superview.
	else if(self.center.x + _radius + _halfMaximumMenuItemDimension >= self.superview.width)
	{
		// Calculate the angle which the circle is intersecting with the right side of the superview. Arccosine can be used because the intersection point of the circle in the top two quadrants can be mirrored along the y-axis to get the intersection point in the bottom two quadrants.
		CGFloat xDifference = self.superview.width - _halfMaximumMenuItemDimension - self.center.x;
		CGFloat rightIntersectionAngle = acosf(xDifference / _radius);
		
		if(intersectsTop == YES)
		{
			// Calculate the angle which the circle is intersecting with the top side of the superview.
			CGFloat yDifference = self.center.y - _halfMaximumMenuItemDimension;
			CGFloat topIntersectionAngle = (M_PI_2 - acosf(yDifference / _radius)) + M_PI;
			
			_startingAngle = rightIntersectionAngle;
			_populatedAngle = topIntersectionAngle - _startingAngle;
		}
		else if(intersectsBottom == YES)
		{
			// Calculate the angle which the circle is intersecting with the bottom side of the superview.
			CGFloat yDifference = self.center.y + _halfMaximumMenuItemDimension - self.superview.height;
			CGFloat bottomIntersectionAngle = (M_PI_2 - acosf(yDifference / _radius)) + M_PI;
			
			_startingAngle = bottomIntersectionAngle;
			_populatedAngle = 2 * M_PI - rightIntersectionAngle - bottomIntersectionAngle;
		}
		else
		{
			_startingAngle = rightIntersectionAngle;
			_populatedAngle = (2 * M_PI) - _startingAngle - rightIntersectionAngle;
		}
	}
	// If the circle centered around the menu intersects with only the top of the superview use a half circle projected downward.
	else if(intersectsTop == YES)
	{
		// Calculate the angle which the circle is intersecting with the top side of the superview.
		CGFloat topIntersectionAngle = M_PI_2 - acosf((self.center.y - _halfMaximumMenuItemDimension) / _radius);
		
		_startingAngle = -topIntersectionAngle;
		_populatedAngle = M_PI + (2 * topIntersectionAngle);
	}
	// If the circle centered around the menu intersects with only the bottom of the superview use a half circle projected upwards.
	else if(intersectsBottom == YES)
	{
		// Calculate the angle which the circle is intersecting with the bottom side of the superview.
		CGFloat bottomIntersectionAngle = M_PI_2 - acosf((self.superview.height - _halfMaximumMenuItemDimension - self.center.y) / _radius);
		
		_startingAngle = -M_PI - bottomIntersectionAngle;
		_populatedAngle = M_PI + (2 * bottomIntersectionAngle);
	}
	
	// Calculate the needed item spacing to have all the items positioned equally around the circle.
	if(_populatedAngle >= 2.0f * M_PI)
	{
		_itemSpacing = _populatedAngle / [_items count];
	}
	else
	{
		_itemSpacing = _populatedAngle / ([_items count] - 1);
	}
	
	// Ensure the radius of the circle is large enough so no items overlap one another. The distance between two items should be at least the maximum dimension of the menu items.
	// NOTE: The distance between two points along the circumference is distance^2 = radius^2 * 2(1 - cos(theta)) where theta is the angle between the two points. This can be reduced to radius = sqrt(distance^2 / 2(1 - cos(theta))).
	CGFloat distanceSquared = powf(_halfMaximumMenuItemDimension * 2, 2);
	CGFloat angleMath = 1 - cosf(_itemSpacing);
	
	CGFloat minimumRadius = sqrtf(distanceSquared / (2 * angleMath));
	if (minimumRadius > _radius 
		&& ABS(minimumRadius - _radius) > 1.0f)
	{
		_radius = minimumRadius;
		
		[self _calculateMinimumRequiredRadius];
	}
}

- (void)_refreshRadiusAndAngles
{
	// Start out ignoring the possibility of items overlapping one another and set the radius to be the desired radius.
	_radius = _desiredRadius;
	
	// Calculate the starting and populated angles for the current radius. If the item spacing is too large for the radius increase the radius and recalculate the starting and populating angles until they are big enough.
	[self _calculateMinimumRequiredRadius];
	
#if DEBUG_DRAWINGS
	// Update the various debugs views to represent the new radius and angles being used.
	CGRect outlineRect = CGRectMake(_halfMaximumMenuItemDimension, _halfMaximumMenuItemDimension, self.superview.width - _halfMaximumMenuItemDimension * 2, self.superview.height - _halfMaximumMenuItemDimension * 2);
	[_outlineView setPixelSnappedFrame: outlineRect];
	
	_desiredRadiusCircle.width = _radius * 2;
	_desiredRadiusCircle.height = _radius * 2;
	_desiredRadiusCircle.center = self.center;
	_desiredRadiusCircle.startingAngle = _startingAngle;
	_desiredRadiusCircle.endingAngle = _startingAngle + _populatedAngle;
	
	_outlineCircle.width = _desiredRadius * 2;
	_outlineCircle.height = _desiredRadius * 2;
	_outlineCircle.center = self.center;
	_outlineCircle.startingAngle = _startingAngle;
	_outlineCircle.endingAngle = _startingAngle + _populatedAngle;
#endif
}

- (void)_openMenu
{
	_menuOpen = YES;
	
	[self _refreshRadiusAndAngles];
	
	__block CGFloat angle = _startingAngle;
	__block NSTimeInterval delay = 0.0;
	[_items enumerateObjectsUsingBlock: ^(FDRadialMenuItem *radialMenuItem, NSUInteger index, BOOL *stop)
		{
			if ([radialMenuItem _view].superview == nil)
			{
				[radialMenuItem _view].center = self.center;
				[radialMenuItem _view].transform = CGAffineTransformMakeScale(0.3f, 0.3f);
				[radialMenuItem _setTarget: self 
					action: @selector(_radialMenuItemPressed:)];
				
				[self.superview insertSubview: [radialMenuItem _view] 
					belowSubview: self];
			}
			
			[UIView animateWithDuration: 0.6 
				delay: delay 
				usingSpringWithDamping: 0.6f 
				initialSpringVelocity: 3.0f 
				options: UIViewAnimationOptionAllowUserInteraction 
				animations: ^
					{
						CGFloat x = self.center.x + _radius * cosf(angle);
						CGFloat y = self.center.y + _radius * sinf(angle);
						CGPoint center = CGPointMake(x, y);
						[[radialMenuItem _view] setPixelSnappedCenter: center];
						
						[radialMenuItem _view].transform = CGAffineTransformMakeScale(1.0f, 1.0f);
						
						angle += _itemSpacing;
						delay += 0.05;
					} 
				completion: nil];
		}];
}

- (void)_closeMenu
{
	_menuOpen = NO;
	
	[UIView animateWithDuration: 0.3 
		delay: 0.0 
		options: UIViewAnimationOptionBeginFromCurrentState 
		animations: ^
			{
				[_items enumerateObjectsUsingBlock: ^(FDRadialMenuItem *radialMenuItem, NSUInteger index, BOOL *stop)
					{
						[radialMenuItem _view].center = self.center;
						[radialMenuItem _view].alpha = 0.0f;
						[radialMenuItem _view].transform = CGAffineTransformMakeScale(0.3f, 0.3f);
					}];
			} 
		completion: ^(BOOL finished)
			{
				[_items enumerateObjectsUsingBlock: ^(FDRadialMenuItem *radialMenuItem, NSUInteger index, BOOL *stop)
					{
						[radialMenuItem _view].alpha = 1.0f;
						[[radialMenuItem _view] removeFromSuperview];
					}];
			}];
}

- (void)_toggleMenu
{
	if (_menuOpen == NO)
	{
		[self _openMenu];
	}
	else
	{
		[self _closeMenu];
	}
}

- (void)_radialMenuItemPressed: (FDRadialMenuItem *)selectedRadialMenuItem
{
	// If a menu item is pressed, animate all other items back to the menu and then grow and fade the selected item to indicate that it has been selected.
	_menuOpen = NO;
	
	[UIView animateWithDuration: 0.3 
		delay: 0.0 
		options: UIViewAnimationOptionBeginFromCurrentState 
		animations: ^
			{
				[_items enumerateObjectsUsingBlock: ^(FDRadialMenuItem *radialMenuItem, NSUInteger index, BOOL *stop)
					{
						if (radialMenuItem != selectedRadialMenuItem)
						{
							[radialMenuItem _view].center = self.center;
							[radialMenuItem _view].alpha = 0.0f;
							[radialMenuItem _view].transform = CGAffineTransformMakeScale(0.3f, 0.3f);
						}
					}];
			} 
		completion: ^(BOOL finished)
			{
				[_delegate radialMenu: self 
					didSelectItem: selectedRadialMenuItem];
			}];
	
	[UIView animateWithDuration: 0.5 
		delay: 0.2 
		options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState 
		animations: ^
			{
				[selectedRadialMenuItem _view].alpha = 0.0f;
				[selectedRadialMenuItem _view].transform = CGAffineTransformMakeScale(2.0f, 2.0f);
			} 
		completion: ^(BOOL finished)
			{
				[_items enumerateObjectsUsingBlock: ^(FDRadialMenuItem *radialMenuItem, NSUInteger index, BOOL *stop)
					{
						[radialMenuItem _view].alpha = 1.0f;
						[[radialMenuItem _view] removeFromSuperview];
					}];
			}];
}

- (void)_setupDynamicAnimator
{
	if (_dynamicAnimator == nil 
		&& self.superview != nil)
	{
		_dynamicAnimator = [[UIDynamicAnimator alloc] 
			initWithReferenceView: self.superview];
		
		[_dynamicAnimator addBehavior: _dynamicItemBehavior];
	}
}

- (void)_handlePanGestureRecognized: (UIPanGestureRecognizer *)panGestureRecognizer
{
	if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
	{
		// Ensure the menu is closed when the menu is moving.
		[self _closeMenu];
		
		// Remove the collision behaviour because UIAttachmentBehavior has some weird bug where if the length of the attachment behaviour is 0 you can't slide the attached view along the colliding view.
		[_dynamicAnimator removeBehavior: _collisionBehavior];
		
		// Update the anchor point of the attachment behaviour to be the center of the menu and add it to the animator.
		_attachmentBehavior.anchorPoint = panGestureRecognizer.view.center;
		[_dynamicAnimator addBehavior: _attachmentBehavior];
	}
	else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
	{
		// Update the anchor point of the attachment behaviour to keep the menu under the user's finger.
		CGPoint location = [panGestureRecognizer locationInView: panGestureRecognizer.view.superview];
		_attachmentBehavior.anchorPoint = location;
	}
	else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
	{
		// Remove the attachment behaviour so the menu can "fly" around the screen.
		[_dynamicAnimator removeBehavior: _attachmentBehavior];
		
		// Re-add the collision behaviour so the menu doesn't fly off screen.
		[_dynamicAnimator addBehavior: _collisionBehavior];
		
		// Add the velocity of the pan gensture recognizer to the dynamic item behaviour so the meny gets "flung" around the screen.
		CGPoint velocity = [panGestureRecognizer velocityInView: panGestureRecognizer.view.superview];		
		[_dynamicItemBehavior addLinearVelocity: velocity 
			forItem: self];
	}
}


@end