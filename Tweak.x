#import <UIKit/UIKit.h>
#import <dlfcn.h>

@interface BCBatteryDeviceController : NSObject
+(id)_sharedPowerSourceController;
@end

@interface ComplicationsView : UIView
@end

static NSNumber *yOffset = nil;



%group CrashFix /* Fixes safemode crash */
%hook BCBatteryDeviceController
%new
+(id)sharedInstance {
	return [%c(BCBatteryDeviceController) _sharedPowerSourceController];
}
%end
%end



%group UIFix /* Fixes media player offset bug */
%hook ComplicationsView // ui fix made by AlexBurneikis
-(void)setFrame:(CGRect)frame {
	%orig;

	// The first time this method is called we need to get the y offset from the original preferences
	if (yOffset == nil) {
		NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.bengiannis.complicationsprefs"];
		yOffset = [defaults objectForKey:@"yOffset"] ?: @0;
	}

	// Get the height of the sibling UIStackView
	UIStackView *stackView = nil;
	for (UIView *view in self.superview.subviews) {
		if ([view isKindOfClass:%c(UIStackView)]) {
			stackView = (UIStackView *)view;
			break;
		}
	}
	CGFloat height = stackView.frame.size.height - 50;

	// Change the y position of the complication view center
	self.center = CGPointMake(self.center.x, ([yOffset floatValue] - height) - 45);
}

%end
%end



%ctor {
	%init(CrashFix);

	// find Complications.dylib and load it, before initialising the remaining hooks
	NSString *path = @"/Library/MobileSubstrate/DynamicLibraries/Complications.dylib"; // regular
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = @"/var/jb/Library/MobileSubstrate/DynamicLibraries/Complications.dylib"; // rootless
	}
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		void *handle = dlopen([path UTF8String], RTLD_LAZY);
		if (handle) %init(UIFix);
	} // else complications is not installed :fr:
}
