
#import "RSSFlocksView.h"

#import "RSSFlocksConfigurationWindowController.h"

#import "RSSUserDefaults+Constants.h"

#import "RSSFlocksSettings.h"

#import "Flocks.h"

#import <OpenGL/gl.h>

@interface RSSFlocksView ()
{
	BOOL _preview;
	BOOL _mainScreen;
	
	BOOL _OpenGLIncompatibilityDetected;
	
	NSOpenGLView *_openGLView;
	
	scene *_scene;
	
	// Preferences
	
	RSSFlocksConfigurationWindowController *_configurationWindowController;
}

+ (void)_initializeScene:(scene *)inScene withSettings:(RSSFlocksSettings *)inSettings;

@end

@implementation RSSFlocksView

+ (void)_initializeScene:(scene *)inScene withSettings:(RSSFlocksSettings *)inSettings
{
	inScene->leadersCount=(int)inSettings.numberOfLeaders;
	inScene->followersCount=(int)inSettings.numberOfFollowers;
	
	inScene->geometryType=(int)inSettings.geometryType;
	inScene->blobComplexity=(int)inSettings.blobGeometryComplexity;
	
	inScene->bugSpeed=(int)inSettings.bugSpeed;
	inScene->bugSize=(int)inSettings.bugSize;
	
	inScene->stretch=(int)inSettings.stretch;
	inScene->colorFade=((float)inSettings.colorFadeSpeed)*0.01;
	
	inScene->stereoscopicRendering=(inSettings.stereoscopicRendering==YES);
	inScene->showConnections=(inSettings.showConnections==YES);
}

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

#pragma mark -

- (void)startAnimation
{
	_OpenGLIncompatibilityDetected=NO;
	
	[super startAnimation];
	
	NSString *tIdentifier = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
	ScreenSaverDefaults *tDefaults = [ScreenSaverDefaults defaultsForModuleWithName:tIdentifier];
	
	BOOL tBool=[tDefaults boolForKey:RSSUserDefaultsMainDisplayOnly];
	
	if (tBool==YES && _mainScreen==NO)
		return;
	
	// Add OpenGLView
	
	NSOpenGLPixelFormatAttribute attribs[] =
	{
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize,(NSOpenGLPixelFormatAttribute)16,
		NSOpenGLPFAMinimumPolicy,
		(NSOpenGLPixelFormatAttribute)0
	};
	
	NSOpenGLPixelFormat *tFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
	
	if (tFormat==nil)
	{
		_OpenGLIncompatibilityDetected=YES;
		return;
	}
	_openGLView = [[NSOpenGLView alloc] initWithFrame:[self bounds] pixelFormat:tFormat];
	
	if (_openGLView!=nil)
	{
		[_openGLView setWantsBestResolutionOpenGLSurface:YES];
		
		[self addSubview:_openGLView];
	}
	else
	{
		_OpenGLIncompatibilityDetected=YES;
		return;
	}
	
	[[_openGLView openGLContext] makeCurrentContext];
	
	NSRect tPixelBounds=[_openGLView convertRectToBacking:[_openGLView bounds]];
	NSSize tSize=tPixelBounds.size;
	
	_scene=new scene();
	
	if (_scene!=NULL)
	{
		[RSSFlocksView _initializeScene:_scene
							withSettings:[[RSSFlocksSettings alloc] initWithDictionaryRepresentation:[tDefaults dictionaryRepresentation]]];
		
		_scene->resize((int)tSize.width, (int)tSize.height);
		_scene->create();
	}
	
	const GLint tSwapInterval=1;
	CGLSetParameter(CGLGetCurrentContext(), kCGLCPSwapInterval,&tSwapInterval);
}

- (void)stopAnimation
{
	[super stopAnimation];
	
	if (_scene!=NULL)
	{
		delete _scene;
		_scene=NULL;
	}
}

- (void)animateOneFrame
{
	if (_openGLView!=nil)
	{
		[[_openGLView openGLContext] makeCurrentContext];
		
		if (_scene!=NULL)
			_scene->draw();
		
		[[_openGLView openGLContext] flushBuffer];
	}
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
