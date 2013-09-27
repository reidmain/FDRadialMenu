#pragma mark Forward Declarations

@class FDRadialMenu;
@class FDRadialMenuItem;


#pragma mark - Protocol

@protocol FDRadialMenuDelegate<NSObject>


#pragma mark - Required Methods

@required

- (void)radialMenu: (FDRadialMenu *)radialMenu 
	didSelectItem: (FDRadialMenuItem *)radialMenuItem;


@end