//
//  FilterPlayerSeekBar.m
//  TheFilter
//
//  Created by Ben Hine on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterPlayerSeekBar.h"
#import "Common.h"
#import "FilterPlayerController.h"

#define PROGRESS_BACKGROUND_RECT CGRectMake(50, 21, 220, 9)

@implementation FilterPlayerSeekBar
@synthesize currentProgress = currentProgress_;
@synthesize totalLength = totalLength_;
@synthesize downloadProgress = downloadProgress_;
@synthesize scrubbing;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.backgroundColor = [UIColor clearColor];
		
		leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 1, 40, 25)];
		leftLabel.backgroundColor = [UIColor clearColor];
		leftLabel.textColor = [UIColor colorWithRed:0.9 green:0.89 blue:0.89 alpha:1];
		leftLabel.textAlignment = UITextAlignmentCenter;
		leftLabel.font = FILTERFONT(12);
		leftLabel.adjustsFontSizeToFitWidth = YES;
		leftLabel.minimumFontSize = 10;
		leftLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		leftLabel.shadowColor = [UIColor blackColor];
		leftLabel.shadowOffset = CGSizeMake(0, 1);
		leftLabel.text = @"0:00";
		[self addSubview:leftLabel];
		
		rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(275, 1, 41, 25)];
		rightLabel.backgroundColor = [UIColor clearColor];
		rightLabel.textColor = [UIColor colorWithRed:0.9 green:0.89 blue:0.89 alpha:1];
		rightLabel.font = FILTERFONT(12);
		rightLabel.adjustsFontSizeToFitWidth = YES;
		rightLabel.minimumFontSize = 10;
		rightLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		rightLabel.shadowColor = [UIColor blackColor];
		rightLabel.shadowOffset = CGSizeMake(0, 1);
		rightLabel.textAlignment = UITextAlignmentCenter;
		rightLabel.text = @"-0:00";
		[self addSubview:rightLabel];
		
		
		progressBackground = [[UIImageView alloc] initWithFrame:CGRectMake(50, 9, 220, 9)];
		progressBackground.image = [UIImage imageNamed:@"music_progress_bkg.png"];
		//[self addSubview:progressBackground];
				
		downloadProgressImage = [[UIImage imageNamed:@"music_progress_download.png"]retain];
		
		playProgressImage = [[UIImage imageNamed:@"music_progress.png"] retain];
		
		buttonImage = [[UIImage imageNamed:@"music_control.png"] retain];
		
		scrubbing = NO;
		
		
		//testing
		totalLength_ = 100;
		currentProgress_ = 0;
		
		
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"m:ss"];
		
		
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	
	//TODO: draw the thumb image, download and play progress
	
	//CGFloat downloadPixels = 50;
	
	CGFloat downloadPixels = (downloadProgress_ / totalLength_) * progressBackground.frame.size.width;
	
	//CGFloat currentPixels = 50;
	CGFloat currentPixels = (currentProgress_ / totalLength_) * progressBackground.frame.size.width;
	
	//NSLog(@"downloadPixels %1.0f currentPixels %1.0f",downloadPixels,currentPixels);
	
	CGContextRef cxt = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(cxt, 0, rect.size.height);
	CGContextScaleCTM(cxt, 1, -1);
	
	
	
	CGRect progressRect = PROGRESS_BACKGROUND_RECT;
	
	CGRect downloadRect = CGRectMake(progressRect.origin.x,
									 progressRect.origin.y, 
									 downloadPixels,
									 progressBackground.frame.size.height);
	
	CGRect playRect = CGRectMake(progressRect.origin.x, 
								 progressRect.origin.y, 
								 currentPixels,
								 progressRect.size.height);
	
	CGRect buttonRect = CGRectMake(currentPixels - 11 + progressRect.origin.x, 
								   15, 
								   23, 23);
	
	
	
	CGContextSaveGState(cxt);
	
	CGContextClipToRect(cxt, progressRect);
	
	
	
	CGContextDrawImage(cxt, progressRect, [progressBackground.image CGImage]);
	
	CGContextRestoreGState(cxt);
	CGContextSaveGState(cxt);
	
	CGContextClipToRect(cxt, downloadRect);
	
	CGContextDrawImage(cxt, progressRect, [downloadProgressImage CGImage]);
	
	CGContextRestoreGState(cxt);
	CGContextSaveGState(cxt);
	
	
	CGContextClipToRect(cxt, playRect);
	
	CGContextDrawImage(cxt, progressRect, [playProgressImage CGImage]);
	
	CGContextRestoreGState(cxt);
	
	CGContextDrawImage(cxt, buttonRect, [buttonImage CGImage]);
	
	
}

-(void)resetBar {
	
	currentProgress_ = 0;
	
	totalLength_ = 100;
	leftLabel.text = @"0:00";
	rightLabel.text = @"-0:00";
	
	[self setNeedsDisplay];
	
}



-(void)setCurrentProgress:(CGFloat)progress {
	
	currentProgress_ = progress;
	
	
		NSInteger totalInt = (NSInteger)totalLength_;
		NSInteger progInt = (NSInteger)progress;
	
		leftLabel.text = [NSString stringWithFormat:@"%d:%02d",progInt / 60,progInt % 60];
		rightLabel.text = [NSString stringWithFormat:@"-%d:%02d",(totalInt - progInt) / 60, (totalInt - progInt) % 60];
	
	[self setNeedsDisplay];
}

-(void)setDownloadProgress:(CGFloat)prog {

	downloadProgress_ = prog;
	
		[self setNeedsDisplay];
	
}


- (void)dealloc {
    [super dealloc];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//grab the button
	// NSLog(@"touchXPoint: %1.0f calculatedCenter: %1.0f",[[touches anyObject] locationInView:self].x,(currentProgress_ / totalLength_ * progressBackground.frame.size.width + 50));
	
	if (fabs([[touches anyObject] locationInView:self].x - (currentProgress_ / totalLength_ * progressBackground.frame.size.width + 50)) < 20) {
		
		scrubbing = YES;
		
	}
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
	if(scrubbing) {
		CGFloat xPoint = [[touches anyObject] locationInView:self].x - 50;
		CGFloat clampedTouchLocation = (xPoint < 0) ? 0 : MIN(xPoint, progressBackground.frame.size.width);
		
		self.currentProgress = (clampedTouchLocation) * totalLength_ / progressBackground.frame.size.width;
		[self setNeedsDisplay];
	}
	
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	scrubbing = NO;
	
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if(scrubbing) {
		[[FilterPlayerController sharedInstance] userFinishedScrubbing];
		scrubbing = NO;
	}
}


@end
