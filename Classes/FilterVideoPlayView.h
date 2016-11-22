//
//  FilterVideoPlayView.h
//  TheFilter
//
//  Created by Jerry on 9/26/13.
//
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "FilterBandVideoTableController.h"
@class FilterTrack;

@interface FilterVideoPlayView :
 FilterView  {
    
    UIWebView *youTubeView_;
    UIImageView *toolBar;
    FilterTrack *currentTrack_;
     
 }

@property (nonatomic, retain) UIWebView *youTubeView;
@property (nonatomic, retain) FilterVideo *ytVideo;
@property (nonatomic, retain) FilterTrack *currentTrack;

- (void)setVideoData:(FilterVideo *) video;

 @end
