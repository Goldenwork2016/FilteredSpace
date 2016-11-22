//
//  FilterBandVideoTableController.m
//  TheFilter
//
//  Created by John Thomas on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterBandVideoTableController.h"
#import "FilterBandVideoTableCell.h"
#import "FilterPlayerController.h"

#import "Common.h"
#import "FilterYoutubeView.h"
//#import "YouTubeViewController.h"

@implementation FilterBandVideoTableController

@synthesize bandProfile = bandProfile_;
@synthesize videoTable = videoTable_;
@synthesize bandVideos = bandVideos_;
@synthesize youTubeView;
@synthesize stackController;
@synthesize currentTrack = currentTrack_;

/*
- (id)initYouTubeView:(FilterYoutubeView *)youTView {
    self = [super init];
    if (self != nil) {
		youTubeView_ = youTView;
		
	}
    
    return self;
}
*/

- (id)initWithHeader:(UIView*)header {
	
	self = [super init];
	
	if (self != nil) {		
		headerView = header;
        bandVideos_ = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc {
	
    [bandVideos_ release], bandVideos_ = nil;
	[super dealloc];
}

- (void)configureTable:(UITableView *)tableView {
	
	tableView.separatorColor = [UIColor blackColor];
    //tableView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
    tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark -
#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [bandVideos_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FilterBandVideoTableCell *cell = (FilterBandVideoTableCell*)[tableView dequeueReusableCellWithIdentifier:@"bandVideoCell"];
	if(!cell) {
		cell = [[[FilterBandVideoTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bandVideoCell"] autorelease];
	}
	FilterVideo *video = [bandVideos_ objectAtIndex:indexPath.row];
    
    int minutes = [video.durationSeconds intValue];
    int hours   = minutes / 60;
    minutes = minutes % 60;
    
    cell.nameLabel.text = video.title;
    cell.durationLabel.text = [NSString stringWithFormat:@"%d:%02d",hours,minutes];
    
    NSURL *url = [NSURL URLWithString:video.thumbnail];
    NSData *data = [[NSData alloc]initWithContentsOfURL:url ];
    UIImage *img = [[UIImage alloc]initWithData:data ];
    cell.videoImage.image=img;

	//cell.webView = [[FilterYoutubeView alloc] initWithStringAsURL:video.url frame:CGRectMake(5, 7, 60, 45)];
    /*
    //passing the id instead of the url   JDH Sept,2013
    cell.webView = [[FilterYoutubeView alloc] initWithStringAsURL:video.id frame:CGRectMake(5, 7, 60, 45)];
    [cell.contentView addSubview:cell.webView];
     */
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FilterVideo *video = [bandVideos_ objectAtIndex:indexPath.row];
    
    NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
    
    //Pause audio if a song is playing
    if([[FilterPlayerController sharedInstance] currentTrack] != nil
       && [[FilterPlayerController sharedInstance] playerState] == kPlayerStatePlaying) {
        [[FilterPlayerController sharedInstance] pauseCurrentTrack];
    }
    
    [data setObject:@"playBandVideo" forKey:@"viewToPush"];
	[data setObject:video forKey:@"video"];
    
 	[self.stackController pushFilterViewWithDictionary:data];
   
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	UIImageView *backgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 23)] autorelease];
	backgroundView.image = [UIImage imageNamed:@"header_bar.png"];
	
	UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 180, 23)] autorelease];
	headerLabel.font = FILTERFONT(12);
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.adjustsFontSizeToFitWidth = YES;
	headerLabel.minimumFontSize = 10;
	headerLabel.textAlignment = UITextAlignmentLeft;
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.text = @"Videos";
	[backgroundView addSubview:headerLabel];
	
	return backgroundView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 23;
}

@end
