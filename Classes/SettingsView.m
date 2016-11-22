//
//  SettingsView.m
//  TheFilter
//
//  Created by Ben Hine on 3/8/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "SettingsView.h"
#import "FilterToolbar.h"
#import "FilterToolbar.h"
#import "FilterCache.h"

@implementation SettingsView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		settingsTable_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
		settingsTable_.delegate = self;
		settingsTable_.dataSource = self;
		settingsTable_.backgroundColor = [UIColor clearColor];
		settingsTable_.separatorColor = [UIColor blackColor];	
		
		[self addSubview:settingsTable_];
    }
    return self;
}

-(void)configureToolbar {
	
	FilterToolbar* toolbar = [FilterToolbar sharedInstance];
	[toolbar showPrimaryLabel:@"Settings"];
	[toolbar showSecondaryLabel:nil];
	[toolbar showPlayerButton:YES];
	[toolbar setLeftButtonWithType:kToolbarButtonTypeBackButton];
	[toolbar showSecondaryToolbar:kSecondaryToolbar_None];

}

- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark UITableView Delegate/Datasource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {	
        switch (indexPath.row) {

            case kEditProfileRow: {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"createAccountView",@"viewToPush",nil];
                [self.stackController pushFilterViewWithDictionary:dict];
            }
                break;

            case kServicesRow: {
                
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"socialServices",@"viewToPush",nil];
                [self.stackController pushFilterViewWithDictionary:dict];
            }
                break;
            case kChangePassword:{
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"changePassword", @"viewToPush", nil];
                [self.stackController pushFilterViewWithDictionary:dict];
            }
                break;
            default:
                break;
        }
    }
    else {
        UIAlertView *logout = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to logout?"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"OK", nil];
        [logout show];
        [logout release];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
	
	if(!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingsCell"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		
		cell.textLabel.font = FILTERFONT(16);
		cell.textLabel.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];

		cell.detailTextLabel.font = FILTERFONT(16);
		cell.detailTextLabel.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];
	}	
	
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case kEditProfileRow:
                cell.textLabel.text = @"Edit Profile";
                break;
                
            case kServicesRow:
                cell.textLabel.text = @"Services";
                break;
            case kChangePassword:
                cell.textLabel.text = @"Change password";
                break;
            default:
                break;
        }
    }
    else
    {
        cell.textLabel.text = @"Logout";
    }
    
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 0 ? 3 : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        UIView *backgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
        
        UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 180, 25)] autorelease];
        headerLabel.font = FILTERFONT(18);
        headerLabel.textColor = [UIColor colorWithRed:0.83 green:0.85 blue:0.85 alpha:1.0];
        headerLabel.text = @"Settings";
        headerLabel.textAlignment = UITextAlignmentLeft;
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.shadowColor = [UIColor blackColor];
        headerLabel.shadowOffset = CGSizeMake(0, 1);
        [backgroundView addSubview:headerLabel];
        
        return backgroundView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 35;
}

#pragma mark - 
#pragma mark UIAlertViewDelegate conformance

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        
    }
    else {
        //HORRIBLE I know but its to get around all the current problems
        [self.stackController logout];
    }
}

@end
