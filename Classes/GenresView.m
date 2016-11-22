//
//  GenresView.m
//  TheFilter
//
//  Created by Ben Hine on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenresView.h"
#import "FilterToolbar.h"
#import "FilterDataObjects.h"
#import "FilterAPIOperationQueue.h"

#define LIGHT_TEXT_COLOR [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1]
#define DARK_TEXT_COLOR [UIColor colorWithRed:0.55 green:0.58 blue:0.58 alpha:1]

#define BACKGROUND_COLOR [UIColor clearColor]

@implementation GenresView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        /*  JDH do we really need a background image here?
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
        backgroundImage.frame = CGRectMake(0, -65, 320, 480);
        [self addSubview:backgroundImage];
        */
        
        // Initialization code.
		genresTable_				= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
		genresTable_.separatorColor = [UIColor blackColor];
		genresTable_.delegate		= self;
		genresTable_.dataSource		= self;
        genresTable_.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
        genresTable_.backgroundView.backgroundColor = [UIColor blackColor];
		
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        
        headerView.backgroundColor = [UIColor blackColor];

		UILabel *headerLabel;
		headerLabel					= [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 320, 27)];
		//headerLabel.backgroundColor = BACKGROUND_COLOR;
        //headerLabel.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
        headerLabel.backgroundColor = [UIColor blackColor];
        
		headerLabel.font			= FILTERFONT(18);
		headerLabel.textColor		= LIGHT_TEXT_COLOR;
		headerLabel.shadowColor		= [UIColor blackColor];
		headerLabel.shadowOffset	= CGSizeMake(0,1);
		headerLabel.text			= @"Select your genres of interest";
		[headerView addSubview:headerLabel];
		[genresTable_ setTableHeaderView:headerView];
        
        [headerLabel release];
		[headerView release];
        
//		UIView *bgroundView			= [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
//		bgroundView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
//		genresTable_.backgroundView = bgroundView;
        
        //JDH Attempt to fix wierd background...
//		genresTable_.backgroundColor = [UIColor clearColor];
//        genresTable_.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
        
		[self addSubview:genresTable_];
		
		genres_ = [[NSMutableArray alloc] initWithCapacity:0];
		checked_ = [[NSArray alloc] init];
        
        indicator = [[LoadingIndicator alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height) andType:kLargeIndicator];
        indicator.message.text = @"Loading...";
        
        [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:nil andType:kFilterAPITypeGetGenres andCallback:self];
    
        [self addSubview:indicator];
        [indicator startAnimating];
    }
    return self;
}

-(void)configureToolbar {
	FilterToolbar* toolbar = [FilterToolbar sharedInstance];
	[toolbar showPrimaryLabel:@"Genres"];
	[toolbar showSecondaryLabel:nil];
	[toolbar showPlayerButton:NO];
	
	//This is hacky and I don't like it, but there's a deadline to meet and this fixes hella bugs
	if(self.stackController.controllerType == AccountStackController) {
		[toolbar setLeftButtonWithType:kToolbarButtonTypeNone];
	} else {
		[toolbar setLeftButtonWithType:kToolbarButtonTypeBackButton];
	}
    
	[toolbar setRightButtonWithType:kToolbarButtonTypeDone];
	[toolbar showSecondaryToolbar:kSecondaryToolbar_None];
	
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Button clicked methods
- (void)donePushed:(id)button {
	
	//This is hacky and I don't like it, but there's a deadline to meet and this fixes hella bugs
//	if(self.stackController.controllerType == AccountStackController) {
//
//	
//    } else {
//		[self.stackController popNavigationStack];
//	}
    NSMutableArray *newGenres = [[[NSMutableArray alloc] init] autorelease];
    
    for(int i = 0; i < [checked_ count]; i++) {
        if([[checked_ objectAtIndex:i] isEqualToString:@"YES"]) {
            
            FilterGenre *aGenre = [genres_ objectAtIndex:i];
            
            
            [newGenres addObject:[NSNumber numberWithInt:aGenre.genreID]];
        }
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:newGenres forKey:@"genres"];
    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:params andType:kFilterAPITypeAccountAddGenres andCallback:self];
}

#pragma mark -
#pragma mark UITableViewDelegate/UITableViewDatasource conformance
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (cell.accessoryType == UITableViewCellAccessoryNone) {
		[checked_ replaceObjectAtIndex:indexPath.row withObject:@"YES"];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		[checked_ replaceObjectAtIndex:indexPath.row withObject:@"NO"];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"genreCell"];
	
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"genreCell"] autorelease];
	}	
	
	cell.textLabel.text = [[genres_ objectAtIndex:indexPath.row] name];
	cell.accessoryType = [checked_ objectAtIndex:indexPath.row] == @"YES" ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	cell.textLabel.textColor = LIGHT_TEXT_COLOR;
    cell.textLabel.font = FILTERFONT(16);
	cell.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [genres_ count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

#pragma mark -
#pragma mark FilterAPIOperationDelegate methods

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFinishWithData:(id)data withMetadata:(id)metadata {
	
	switch (filterop.type) {
		case kFilterAPITypeGetGenres:
		{
            [genres_ removeAllObjects];
			[checked_ release];
			
			[genres_ addObjectsFromArray:(NSArray*)data];
			checked_ = [[NSMutableArray alloc] initWithCapacity:0];
			
			for(int i = 0; i < [genres_ count]; i++)
			{
				[checked_ addObject:@"NO"];
			}
            
            if(self.stackController.controllerType != AccountStackController) {
                [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:nil andType:kFilterAPITypeAccountGetGenres andCallback:self];
            }
            else {
                 [indicator stopAnimatingAndRemove];
            }
            
			break;
		}
		case kFilterAPITypeAccountAddGenres:
		{
            if(self.stackController.controllerType == AccountStackController) {
                [self.stackController authorizationDone];
                [self removeFromSuperview];
            }
            else {
                [self.stackController popNavigationStack];
            }
            
            break;
		}
        case kFilterAPITypeAccountGetGenres:
        {
            for(FilterGenre *userGenre in (NSArray *)data) {
                for (int i = 0; i < [genres_ count]; i++) {
                    if(((FilterGenre *)[genres_ objectAtIndex:i]).genreID == userGenre.genreID) {
                        [checked_ replaceObjectAtIndex:i withObject:@"YES"];
                    }
                }
            }
            
            [indicator stopAnimatingAndRemove];
            break;
        }
		default:
			break;
	}
    
    [genresTable_ reloadData];
}

-(void)filterAPIOperation:(ASIHTTPRequest*)filterop didFailWithError:(NSError*)err {
    NSString *title;
    NSString *message;
    
    if ([[err domain] isEqualToString:@"USR"]) {
        title = [[err userInfo] objectForKey:@"name"];
        message = [[err userInfo] objectForKey:@"description"];
    }
    else {
        title = @"Sorry";
        message = @"The Server could not be reached";
    }
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle: title
							   message: message
							   delegate:self
							   cancelButtonTitle:@"OK"
							   otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
    
    [indicator stopAnimatingAndRemove];
}

@end
