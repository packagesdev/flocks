
#import "RSSFlocksView.h"

#import "RSSFlocksConfigurationWindowController.h"

#import "RSSUserDefaults+Constants.h"

#import "RSSFlocksSettings.h"

#import <OpenGL/gl.h>

@implementation RSSFlocksView ()
{
	BOOL _preview;
	BOOL _mainScreen;
	
	BOOL _OpenGLIncompatibilityDetected;
	
	NSOpenGLView *_openGLView;
	
	scene *_scene;
	
	// Preferences
	
	RSSFlocksConfigurationWindowController *_configurationWindowController;
}

@end

@implementation RSSFlocksView

- (instancetype)initWithFrame:(NSRect)frameRect isPreview:(BOOL)isPreview
{
	self=[super initWithFrame:frameRect isPreview:isPreview];
	
	if (self!=nil)
	{
		_preview=isPreview;
		
		if (_preview==YES)
			_mainScreen=YES;
		else
			_mainScreen= (NSMinX(frameRect)==0 && NSMinY(frameRect)==0);
		
		[self setAnimationTimeInterval:0.05];
	}
	
	return self;
}

#pragma mark -

- (void) drawRect:(NSRect) inFrame
{
	[[NSColor blackColor] set];
	
	NSRectFill(inFrame);
	
	if (_OpenGLIncompatibilityDetected==YES)
	{
		BOOL tShowErrorMessage=_mainScreen;
		
		if (tShowErrorMessage==NO)
		{
			NSString *tIdentifier = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
			ScreenSaverDefaults *tDefaults = [ScreenSaverDefaults defaultsForModuleWithName:tIdentifier];
			
			tShowErrorMessage=![tDefaults boolForKey:RSSUserDefaultsMainDisplayOnly];
		}
		
		if (tShowErrorMessage==YES)
		{
			NSRect tFrame=[self frame];
			
			NSMutableParagraphStyle * tMutableParagraphStyle=[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
			[tMutableParagraphStyle setAlignment:NSCenterTextAlignment];
			
			NSDictionary * tAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont systemFontSize]],NSFontAttributeName,
										  [NSColor whiteColor],NSForegroundColorAttributeName,
										  tMutableParagraphStyle,NSParagraphStyleAttributeName,nil];
			
			
			NSString * tString=NSLocalizedStringFromTableInBundle(@"Minimum OpenGL requirements\rfor this Screen Effect\rnot available\ron your graphic card.",@"Localizable",[NSBundle bundleForClass:[self class]],@"No comment");
			
			NSRect tStringFrame;
			
			tStringFrame.origin=NSZeroPoint;
			tStringFrame.size=[tString sizeWithAttributes:tAttributes];
			
			tStringFrame=SSCenteredRectInRect(tStringFrame,tFrame);
			
			[tString drawInRect:tStringFrame withAttributes:tAttributes];
		}
	}
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)animateOneFrame
{
    return;
}

#pragma mark - Configuration

- (BOOL)hasConfigureSheet
{
	return YES;
}

- (NSWindow*)configureSheet
{
	if (_configurationWindowController==nil)
		_configurationWindowController=[[RSSFlocksConfigurationWindowController alloc] init];
	
	NSWindow * tWindow=_configurationWindowController.window;
	
	[_configurationWindowController restoreUI];
	
	return tWindow;
}

@end
