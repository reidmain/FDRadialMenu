#import "FDEaselController.h"
#import "FDEaselView.h"
#import <FDRadialMenu/UIView+Layout.h>


#pragma mark Constants


#pragma mark - Class Extension

@interface FDEaselController ()

@property (nonatomic, retain) IBOutlet FDEaselView *easelView;

- (void)_initializeEaselController;


@end


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation FDEaselController


#pragma mark - Properties


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// Abort if base initializer fails.
	if ((self = [self initWithNibName: @"FDEaselView" 
		bundle: nil]) == nil)
	{
		return nil;
	}

	// Return initialized instance.
	return self;
}

- (id)initWithNibName: (NSString *)nibName 
    bundle: (NSBundle *)bundle
{
	// Abort if base initializer fails.
	if ((self = [super initWithNibName: nibName 
        bundle: bundle]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeEaselController];
	
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
	[self _initializeEaselController];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Destructor

- (void)dealloc 
{
	// nil out delegates of any instance variables.
}


#pragma mark - Public Methods


#pragma mark - Overridden Methods

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad
{
	// Call base implementation.
	[super viewDidLoad];
	
	// Add a radial menu to the view.
	UIImage *fingerprintImage = [UIImage imageNamed:@"radial_menu_icon_fingerprint"];
	
	FDRadialMenuItem *redRadialMenuItem = [[FDRadialMenuItem alloc] 
		initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_red"] 
			highlightedBackgroundImage: nil 
			iconImage: fingerprintImage 
			highlightedIconImage: nil];
	redRadialMenuItem.context = [UIColor colorWithRed: 1.0f 
		green: 0.0f 
		blue: 0.0f 
		alpha: 1.0f];
	
	FDRadialMenuItem *greenRadialMenuItem = [[FDRadialMenuItem alloc] 
		initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_green"] 
			highlightedBackgroundImage: nil 
			iconImage: fingerprintImage 
			highlightedIconImage: nil];
	greenRadialMenuItem.context = [UIColor colorWithRed: 0.0f 
		green: 1.0f 
		blue: 0.0f 
		alpha: 1.0f];
	
	FDRadialMenuItem *blueRadialMenuItem = [[FDRadialMenuItem alloc] 
		initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_blue"] 
			highlightedBackgroundImage: nil 
			iconImage: fingerprintImage 
			highlightedIconImage: nil];
	blueRadialMenuItem.context = [UIColor colorWithRed: 0.0f 
		green: 0.0f 
		blue: 1.0f 
		alpha: 1.0f];
	
	FDRadialMenuItem *yellowRadialMenuItem = [[FDRadialMenuItem alloc] 
		initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_yellow"] 
			highlightedBackgroundImage: nil 
			iconImage: fingerprintImage 
			highlightedIconImage: nil];
	yellowRadialMenuItem.context = [UIColor colorWithRed: 255.0f / 255.0f 
		green: 240.0f / 255.0f 
		blue: 0.0f 
		alpha: 1.0f];
	
	FDRadialMenuItem *orangeRadialMenuItem = [[FDRadialMenuItem alloc] 
		initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_orange"] 
			highlightedBackgroundImage: nil 
			iconImage: fingerprintImage 
			highlightedIconImage: nil];
	orangeRadialMenuItem.context = [UIColor colorWithRed: 255.0f / 255.0f 
		green: 138.0f / 255.0f 
		blue: 0.0f 
		alpha: 1.0f];
	
	FDRadialMenuItem *purpleRadialMenuItem = [[FDRadialMenuItem alloc] 
		initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_purple"] 
			highlightedBackgroundImage: nil 
			iconImage: fingerprintImage 
			highlightedIconImage: nil];
	purpleRadialMenuItem.context = [UIColor colorWithRed: 138.0f / 255.0f 
		green: 0.0f 
		blue: 255.0f / 255.0f 
		alpha: 1.0f];
	
	FDRadialMenuItem *blackRadialMenuItem = [[FDRadialMenuItem alloc] 
		initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_black"] 
			highlightedBackgroundImage: nil 
			iconImage: fingerprintImage 
			highlightedIconImage: nil];
	blackRadialMenuItem.context = [UIColor colorWithWhite: 0.0f 
		alpha: 1.0f];
	
	FDRadialMenuItem *eraserRadialMenuItem = [[FDRadialMenuItem alloc] 
		initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_canvas"] 
			highlightedBackgroundImage: nil 
			iconImage: fingerprintImage 
			highlightedIconImage: nil];
	eraserRadialMenuItem.context = [UIColor colorWithRed: 221.0f / 255.0f 
		green: 221.0f / 255.0f 
		blue: 221.0f / 255.0f 
		alpha: 1.0f];
	
	FDRadialMenu *radialMenu = [[FDRadialMenu alloc] 
		initWithBackgroundImage: [UIImage imageNamed: @"radial_menu_background_red"] 
			highlightedBackgroundImage: nil 
			iconImage: [UIImage imageNamed: @"radial_menu_icon_palette"] 
			highlightedIconImage: nil];
	radialMenu.delegate = self;
	radialMenu.items = @[ redRadialMenuItem, greenRadialMenuItem, blueRadialMenuItem, yellowRadialMenuItem, orangeRadialMenuItem, purpleRadialMenuItem, blackRadialMenuItem, eraserRadialMenuItem ];
	radialMenu.moveable = YES;
	radialMenu.desiredRadius = 90.0f;
	
	[radialMenu setPixelSnappedCenter: CGPointMake(25.0f, self.view.height / 2.0f)];
	
	[self.view addSubview: radialMenu];
	
	// Set the default colour of the easel view to be the first menu item in the radial menu.
	_easelView.backgroundColor = eraserRadialMenuItem.context;
	_easelView.brushColor = [[radialMenu.items firstObject] context];
}


#pragma mark - Private Methods

- (void)_initializeEaselController
{
	// Initialize instance variables.
}


#pragma mark - FDRadialMenuDelegate Methods

- (void)radialMenu: (FDRadialMenu *)radialMenu 
	didSelectItem: (FDRadialMenuItem *)radialMenuItem
{
	radialMenu.backgroundImage = radialMenuItem.backgroundImage;
	
	_easelView.brushColor = radialMenuItem.context;
}


@end