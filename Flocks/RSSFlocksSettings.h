
#import "RSSSettings.h"

typedef NS_ENUM(NSUInteger, RSSFlocksBugGeometryType)
{
	RSSFlocksBugGeometryTypeDot=0,
	RSSFlocksBugGeometryTypeBlob=1
};

@interface RSSFlocksSettings : RSSSettings

@property NSUInteger numberOfLeaders;

@property NSUInteger numberOfFollowers;

@property RSSFlocksBugGeometryType geometryType;

@property NSUInteger blobGeometryComplexity;

@property NSUInteger bugSize;

@property NSUInteger bugSpeed;

@property NSUInteger stretch;

@property NSUInteger colorFadeSpeed;

@property BOOL showConnections;

@property BOOL stereoscopicRendering;

@end
