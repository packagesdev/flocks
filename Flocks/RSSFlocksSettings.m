
#import "RSSFlocksSettings.h"

NSString * const RSSFlocks_Settings_NumberOfLeadersKey=@"Leaders";
NSString * const RSSFlocks_Settings_NumberOfFollowersKey=@"Followers";

NSString * const RSSFlocks_Settings_GeometryTypeKey=@"Geometry";
NSString * const RSSFlocks_Settings_BlobGeometryTypeComplexityKey=@"Complexity";

NSString * const RSSFlocks_Settings_BugSizeKey=@"Size";
NSString * const RSSFlocks_Settings_BugSpeedKey=@"Speed";

NSString * const RSSFlocks_Settings_StretchKey=@"Stretch";
NSString * const RSSFlocks_Settings_ColorFadeSpeedKey=@"ColorFadeSpeed";

NSString * const RSSFlocks_Settings_ShowConnectionsKey=@"Connections";
NSString * const RSSFlocks_Settings_StereoscopicRenderingKey=@"Chromatek";

@implementation RSSFlocksSettings

- (id)initWithDictionaryRepresentation:(NSDictionary *)inDictionary
{
	self=[super init];
	
	if (self!=nil)
	{
		NSNumber * tNumber=inDictionary[RSSFlocks_Settings_NumberOfLeadersKey];
		
		if (tNumber!=nil)
		{
			_numberOfLeaders=[inDictionary[RSSFlocks_Settings_NumberOfLeadersKey] unsignedIntegerValue];
			_numberOfFollowers=[inDictionary[RSSFlocks_Settings_NumberOfFollowersKey] unsignedIntegerValue];
			
			_geometryType=[inDictionary[RSSFlocks_Settings_GeometryTypeKey] unsignedIntegerValue];
			_blobGeometryComplexity=[inDictionary[RSSFlocks_Settings_BlobGeometryTypeComplexityKey] unsignedIntegerValue];
			
			_bugSize=[inDictionary[RSSFlocks_Settings_BugSizeKey] unsignedIntegerValue];
			_bugSpeed=[inDictionary[RSSFlocks_Settings_BugSpeedKey] unsignedIntegerValue];
			
			_stretch=[inDictionary[RSSFlocks_Settings_StretchKey] unsignedIntegerValue];
			_colorFadeSpeed=[inDictionary[RSSFlocks_Settings_ColorFadeSpeedKey] unsignedIntegerValue];
			
			_showConnections=[inDictionary[RSSFlocks_Settings_ShowConnectionsKey] boolValue];
			_stereoscopicRendering=[inDictionary[RSSFlocks_Settings_StereoscopicRenderingKey] boolValue];
		}
		else
		{
			[self resetSettings];
		}
	}
	
	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary * tMutableDictionary=[NSMutableDictionary dictionary];
	
	if (tMutableDictionary!=nil)
	{
		tMutableDictionary[RSSFlocks_Settings_NumberOfLeadersKey]=@(_numberOfLeaders);
		tMutableDictionary[RSSFlocks_Settings_NumberOfFollowersKey]=@(_numberOfFollowers);
		
		tMutableDictionary[RSSFlocks_Settings_GeometryTypeKey]=@(_geometryType);
		tMutableDictionary[RSSFlocks_Settings_BlobGeometryTypeComplexityKey]=@(_blobGeometryComplexity);
		
		tMutableDictionary[RSSFlocks_Settings_BugSizeKey]=@(_bugSize);
		tMutableDictionary[RSSFlocks_Settings_BugSpeedKey]=@(_bugSpeed);
		
		tMutableDictionary[RSSFlocks_Settings_StretchKey]=@(_stretch);
		tMutableDictionary[RSSFlocks_Settings_ColorFadeSpeedKey]=@(_colorFadeSpeed);
		
		tMutableDictionary[RSSFlocks_Settings_ShowConnectionsKey]=@(_showConnections);
		tMutableDictionary[RSSFlocks_Settings_StereoscopicRenderingKey]=@(_stereoscopicRendering);
	}
	
	return [tMutableDictionary copy];
}

#pragma mark -

- (void)resetSettings
{
	_numberOfLeaders=4;
	_numberOfFollowers=400;
	
	_geometryType=RSSFlocksBugGeometryTypeBlob;
	_blobGeometryComplexity=1;
	
	_bugSize=10;
	_bugSpeed=15;
	
	_stretch=20;
	_colorFadeSpeed=15;
	
	_showConnections=NO;
	_stereoscopicRendering=NO;
	
}

@end