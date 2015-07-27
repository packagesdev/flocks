
#import "RSSFlocksConfigurationWindowController.h"

#import "RSSFlocksSettings.h"

@interface RSSFlocksConfigurationWindowController ()
{
	IBOutlet NSSlider *_numberOfLeadersSlider;
	IBOutlet NSTextField *_numberOfLeaderslabel;
	
	IBOutlet NSSlider *_numberOfFollowersSlider;
	IBOutlet NSTextField *_numberOfFollowersLabel;
	
	IBOutlet NSPopUpButton * _geometryTypePopupButton;
	
	IBOutlet NSTextField *_blobComplexityLeftLabel;
	IBOutlet NSSlider *_blobComplexitySlider;
	IBOutlet NSTextField *_blobComplexityLabel;
	
	IBOutlet NSSlider *_bugSizeSlider;
	IBOutlet NSTextField *_bugSizeLabel;
	
	IBOutlet NSSlider *_bugSpeedSlider;
	IBOutlet NSTextField *_bugSpeedLabel;
	
	
	IBOutlet NSSlider *_stretchSlider;
	IBOutlet NSTextField *_stretchLabel;
	
	IBOutlet NSSlider *_colorFadeSpeedSlider;
	IBOutlet NSTextField *_colorFadeSpeedLabel;
	
	IBOutlet NSButton * _showConnectionsCheckBox;
	IBOutlet NSButton * _stereoscopyCheckBox;
	
	NSNumberFormatter * _numberFormatter;
}

- (void)_updateBlobComplexityUI;

- (IBAction)setNumberOfLeaders:(id)sender;
- (IBAction)setNumberOfFollowers:(id)sender;
- (IBAction)setGeometryType:(id)sender;
- (IBAction)setBlobComplexityType:(id)sender;
- (IBAction)setBugSize:(id)sender;
- (IBAction)setBugSpeed:(id)sender;

- (IBAction)setStretch:(id)sender;
- (IBAction)setColorFadeSpeed:(id)sender;


- (IBAction)setShowConnections:(id)sender;
- (IBAction)setStereoscopy:(id)sender;

@end

@implementation RSSFlocksConfigurationWindowController

- (Class)settingsClass
{
	return [RSSFlocksSettings class];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	_numberFormatter=[[NSNumberFormatter alloc] init];
	
	if (_numberFormatter!=nil)
	{
		_numberFormatter.hasThousandSeparators=YES;
		_numberFormatter.localizesFormat=YES;
	}
}

- (void)restoreUI
{
	NSString * tFormattedString;
	
	[super restoreUI];
	
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	[_numberOfLeadersSlider setIntegerValue:tFlocksSettings.numberOfLeaders];
	[_numberOfLeaderslabel setIntegerValue:tFlocksSettings.numberOfLeaders];
	
	[_numberOfFollowersSlider setIntegerValue:tFlocksSettings.numberOfFollowers];
	tFormattedString=[_numberFormatter stringFromNumber:[NSNumber numberWithUnsignedInteger:tFlocksSettings.numberOfFollowers]];
	[_numberOfFollowersLabel setStringValue:tFormattedString];
	
	[_geometryTypePopupButton selectItemWithTag:tFlocksSettings.geometryType];
	
	[_blobComplexitySlider setIntegerValue:tFlocksSettings.blobGeometryComplexity];
	[_blobComplexityLabel setIntegerValue:tFlocksSettings.blobGeometryComplexity];
	
	[self _updateBlobComplexityUI];
	
	[_bugSizeSlider setIntegerValue:tFlocksSettings.bugSize];
	[_bugSizeLabel setIntegerValue:tFlocksSettings.bugSize];
	
	[_bugSpeedSlider setIntegerValue:tFlocksSettings.bugSpeed];
	[_bugSpeedLabel setIntegerValue:tFlocksSettings.bugSpeed];
	
	
	[_stretchSlider setIntegerValue:tFlocksSettings.stretch];
	[_stretchLabel setIntegerValue:tFlocksSettings.stretch];
	
	[_colorFadeSpeedSlider setIntegerValue:tFlocksSettings.colorFadeSpeed];
	[_colorFadeSpeedLabel setIntegerValue:tFlocksSettings.colorFadeSpeed];
	
	
	[_showConnectionsCheckBox setState:(tFlocksSettings.showConnections==YES) ? NSOnState : NSOffState];
	
	[_stereoscopyCheckBox setState:(tFlocksSettings.stereoscopicRendering==YES) ? NSOnState : NSOffState];
}

#pragma mark -

- (void)_updateBlobComplexityUI
{
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	if (tFlocksSettings.geometryType!=RSSFlocksBugGeometryTypeBlob)
	{
		[_blobComplexityLeftLabel setTextColor:[NSColor grayColor]];
		
		[_blobComplexitySlider setEnabled:NO];
		
		[_blobComplexityLabel setHidden:YES];
	}
	else
	{
		[_blobComplexityLeftLabel setTextColor:[NSColor blackColor]];
		
		[_blobComplexitySlider setEnabled:YES];
		
		[_blobComplexityLabel setHidden:NO];
	}
}

- (IBAction)setNumberOfLeaders:(id)sender
{
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	if (tFlocksSettings.numberOfLeaders!=[sender integerValue])
	{
		tFlocksSettings.numberOfLeaders=[sender integerValue];
		
		[_numberOfLeaderslabel setIntegerValue:tFlocksSettings.numberOfLeaders];
	}
}

- (IBAction)setNumberOfFollowers:(id)sender
{
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	if (tFlocksSettings.numberOfFollowers!=[sender integerValue])
	{
		tFlocksSettings.numberOfFollowers=[sender integerValue];
		
		NSString * tFormattedString=[_numberFormatter stringFromNumber:[NSNumber numberWithUnsignedInteger:tFlocksSettings.numberOfFollowers]];
		[_numberOfFollowersLabel setStringValue:tFormattedString];
	}
}

- (IBAction)setGeometryType:(id)sender
{
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	if (tFlocksSettings.geometryType!=[sender selectedTag])
	{
		tFlocksSettings.geometryType=[sender selectedTag];
		
		[self _updateBlobComplexityUI];
	}
}

- (IBAction)setBlobComplexityType:(id)sender
{
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	if (tFlocksSettings.blobGeometryComplexity!=[sender integerValue])
	{
		tFlocksSettings.blobGeometryComplexity=[sender integerValue];
		
		[_blobComplexityLabel setIntegerValue:tFlocksSettings.blobGeometryComplexity];
	}
}

- (IBAction)setBugSize:(id)sender
{
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	if (tFlocksSettings.bugSize!=[sender integerValue])
	{
		tFlocksSettings.bugSize=[sender integerValue];
		
		[_bugSizeLabel setIntegerValue:tFlocksSettings.bugSize];
	}
}

- (IBAction)setBugSpeed:(id)sender
{
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	if (tFlocksSettings.bugSpeed!=[sender integerValue])
	{
		tFlocksSettings.bugSpeed=[sender integerValue];
		
		[_bugSpeedLabel setIntegerValue:tFlocksSettings.bugSpeed];
	}
}


- (IBAction)setStretch:(id)sender
{
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	if (tFlocksSettings.stretch!=[sender integerValue])
	{
		tFlocksSettings.stretch=[sender integerValue];
		
		[_stretchLabel setIntegerValue:tFlocksSettings.stretch];
	}
}

- (IBAction)setColorFadeSpeed:(id)sender
{
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	if (tFlocksSettings.colorFadeSpeed!=[sender integerValue])
	{
		tFlocksSettings.colorFadeSpeed=[sender integerValue];
		
		[_colorFadeSpeedLabel setIntegerValue:tFlocksSettings.colorFadeSpeed];
	}
}


- (IBAction)setShowConnections:(id)sender
{
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	if (tFlocksSettings.showConnections!=([sender state]==NSOnState))
	{
		tFlocksSettings.showConnections=([sender state]==NSOnState);
	}
}

- (IBAction)setStereoscopy:(id)sender
{
	RSSFlocksSettings * tFlocksSettings=(RSSFlocksSettings *) sceneSettings;
	
	if (tFlocksSettings.stereoscopicRendering!=([sender state]==NSOnState))
	{
		tFlocksSettings.stereoscopicRendering=([sender state]==NSOnState);
	}
}

@end
