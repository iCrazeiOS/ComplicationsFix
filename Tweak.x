#import <Foundation/Foundation.h>

// sharedInstance exists in iOS 9-14
// _sharedPowerSourceController exists in iOS 14-16

@interface BCBatteryDeviceController : NSObject
+(id)_sharedPowerSourceController;
@end

%hook BCBatteryDeviceController
/*
	Confirmed this is all that needs fixing for iOS 15
	iOS 16 may require more changes
*/

// create a sharedInstance method that just returns _sharedPowerSourceController
%new
+(id)sharedInstance {
	return [%c(BCBatteryDeviceController) _sharedPowerSourceController];
}
%end
