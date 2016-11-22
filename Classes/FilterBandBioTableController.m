//
//  FilterBandBioTableController.m
//  TheFilter
//
//  Created by John Thomas on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterBandBioTableController.h"
#import "FilterBandBioTableCell.h"
#import "Common.h"

@implementation FilterBandBioTableController

@synthesize bandInfo = bandInfo_;

- (id)initWithHeader:(UIView*)header {
	
	self = [super init];
	
	if (self != nil) {		
		headerView = header;
	}
    
	return self;
}

- (void)dealloc {
	
	[super dealloc];
}

- (void)configureTable:(UITableView *)tableView {
	
	//tableView.tableHeaderView = headerView;
	tableView.separatorColor = [UIColor clearColor];
    //tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor blackColor];
    // JDH
    tableView.backgroundView.backgroundColor = [UIColor blackColor];
}

#pragma mark -
#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return [bandInfo_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FilterBandBioTableCell *cell = (FilterBandBioTableCell*)[tableView dequeueReusableCellWithIdentifier:@"bandBioCell"];
	if(!cell) {
		cell = [[[FilterBandBioTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bandBioCell"] autorelease];
	}
	
	
	// NOTE: Fall through in this switch is intentional. It is to handle missing fields properly
    
    cell.cellTitle.text = [[bandInfo_ objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.cellContent.text = [[bandInfo_ objectAtIndex:indexPath.row] objectForKey:@"content"];
    
    NSString *strToTest = cell.cellContent.text;
	
	CGSize maximumLabelSize = CGSizeMake(280,9999);
	CGSize expectedLabelSize = [strToTest sizeWithFont:FILTERFONT(13) 
									 constrainedToSize:maximumLabelSize 
										 lineBreakMode:UILineBreakModeWordWrap]; 
	
	
	[cell adjustCellFrames:expectedLabelSize];
	
    //JDH
    cell.backgroundColor = [UIColor blackColor];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// many of the numbers used here to determine cell height are drawn from the cell definition in 
	// FilterBanBioTableCell

    NSString *strToTest = [[bandInfo_ objectAtIndex:indexPath.row] objectForKey:@"content"];
    
	CGSize maximumLabelSize = CGSizeMake(280,9999);
	CGSize expectedLabelSize = [strToTest sizeWithFont:FILTERFONT(13) 
									 constrainedToSize:maximumLabelSize 
										 lineBreakMode:UILineBreakModeWordWrap]; 
		
	return expectedLabelSize.height + 20 + 40;		// +20 for the bg padding, +40 to allow for the title content above the bg
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	UIImageView *backgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)] autorelease];
	backgroundView.backgroundColor = [UIColor blackColor];
		
	return backgroundView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 1;
}

@end
