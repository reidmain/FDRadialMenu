#import "AppDelegate.h"
#import "FDEaselController.h"


#pragma mark Class Definition

@implementation AppDelegate
{
	@private __strong UIWindow *_mainWindow;
}


#pragma mark - UIApplicationDelegate Methods

- (BOOL)application: (UIApplication *)application 
	didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	// Create the main window.
	UIScreen *mainScreen = [UIScreen mainScreen];
	
	_mainWindow = [[UIWindow alloc] 
		initWithFrame: mainScreen.bounds];
	
	_mainWindow.backgroundColor = [UIColor blackColor];
	
	// Create the window's root view controller.
	FDEaselController *easelController = [[FDEaselController alloc] 
		initWithDefaultNibName];
	
	_mainWindow.rootViewController = easelController;
	
	// Show the main window.
	[_mainWindow makeKeyAndVisible];
	
	// Indicate success.
	return YES;
}


@end