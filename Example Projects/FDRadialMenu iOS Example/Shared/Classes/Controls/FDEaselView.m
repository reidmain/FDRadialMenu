#import "FDEaselView.h"
#import <FDRadialMenu/UIView+Layout.h>


#pragma mark Constants

#define BrushWidth 60.0f
#define HalfBrushWidth BrushWidth / 2.0f


#pragma mark - Class Extension

@interface FDEaselView ()

- (void)_initializeEaselView;
- (CGContextRef)_newBitmapContextWithSize: (CGSize)size;


@end


#pragma mark - Class Definition

@implementation FDEaselView
{
	@private CGContextRef _bitmapContext;
	@private CGFloat _bitmapContextScaleFactor;
}


#pragma mark - Constructors

- (id)initWithFrame: (CGRect)frame
{
	// Abort if base initializer fails.
	if ((self = [super initWithFrame: frame]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeEaselView];
	
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
	[self _initializeEaselView];
	
	// Return initialized instance.
	return self;
}

#pragma mark - Destructor

- (void)dealloc 
{
	CFRelease(_bitmapContext);
}


#pragma mark - Public Methods

- (void)layoutSubviews
{
	[self setNeedsDisplay];
}


#pragma mark - Overridden Methods

- (void)drawRect: (CGRect)rect
{
	if (_bitmapContext != nil)
	{
		// Get the current context and clip it to the rect so that only visible parts of the image will be redrawn.
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextClipToRect(context, rect);
		
		// Create an image from the bitmap context and render it into the current context.
		CGImageRef image = CGBitmapContextCreateImage(_bitmapContext);
		CFAutorelease(image);
		CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(image) / _bitmapContextScaleFactor, CGImageGetHeight(image) / _bitmapContextScaleFactor);
		CGContextDrawImage(context, imageRect, image);
	}
}

- (void)touchesBegan: (NSSet *)touches 
	withEvent: (UIEvent *)event
{
	[self _drawTouchesIntoImage: touches];
	
	[self setNeedsDisplay];
}

- (void)touchesMoved: (NSSet *)touches 
	withEvent: (UIEvent *)event
{
	[self _drawTouchesIntoImage: touches];
	
	[self setNeedsDisplay];
}


#pragma mark - Private Methods

- (void)_initializeEaselView
{
	// Ensure multiple touch is enabled so the user can paint with both hands.
	self.multipleTouchEnabled = YES;
}

- (void)_drawTouchesIntoImage: (NSSet *)touches;
{
	// If the bitmap context does not exist create it using the current size of the view.
	if (_bitmapContext == nil)
	{
		_bitmapContext = [self _newBitmapContextWithSize: CGSizeMake(self.width, self.height)];
	}
	// If the bitmap context does exist ensure it is big enough for the current size of the view.
	else
	{
		size_t bitmapContextWidth = CGBitmapContextGetWidth(_bitmapContext) / _bitmapContextScaleFactor;
		size_t bitmapContextHeight = CGBitmapContextGetHeight(_bitmapContext) / _bitmapContextScaleFactor;
		
		// If the bitmap context is smaller than the size of the view increase the size of the bitmap context.
		if (bitmapContextWidth < self.width  
			|| bitmapContextHeight < self.height)
		{
			// Create a image of the current bitmap context to be drawn into the new bitmap context.
			CGImageRef image = CGBitmapContextCreateImage(_bitmapContext);
			CFAutorelease(image);
			CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(image) / _bitmapContextScaleFactor, CGImageGetHeight(image) / _bitmapContextScaleFactor);
			
			CFRelease(_bitmapContext);
			
			size_t imageWidth = MAX(self.width, bitmapContextWidth);
			size_t imageHeight = MAX(self.height, bitmapContextHeight);
			_bitmapContext = [self _newBitmapContextWithSize: CGSizeMake(imageWidth, imageHeight)];
			CGContextDrawImage(_bitmapContext, imageRect, image);
		}
	}
	
	// Draw ellipses under each of the touch points.
	CGContextSetFillColorWithColor(_bitmapContext, [_brushColor CGColor]);
	for (UITouch *touch in touches)
	{
		CGPoint touchPoint = [touch locationInView: touch.view];
		
		CGContextFillEllipseInRect(_bitmapContext, CGRectMake(touchPoint.x - HalfBrushWidth, touchPoint.y - HalfBrushWidth, BrushWidth, BrushWidth));
	}
}

- (CGContextRef)_newBitmapContextWithSize: (CGSize)size
{
	UIScreen *mainScreen = [UIScreen mainScreen];
	_bitmapContextScaleFactor = mainScreen.scale;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CFAutorelease(colorSpace);
	
	CGContextRef context = CGBitmapContextCreate(NULL, 
		size.width * _bitmapContextScaleFactor, 
		size.height * _bitmapContextScaleFactor, 
		8, 
		size.width * _bitmapContextScaleFactor * 4,
		colorSpace, 
		kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
	
	CGContextScaleCTM(context, _bitmapContextScaleFactor, _bitmapContextScaleFactor);
	
	return context;
}


@end