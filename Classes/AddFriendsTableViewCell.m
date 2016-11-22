//
//  AddFriendsTableViewCell.m
//  TheFilter
//
//  Created by John Thomas on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddFriendsTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"

@implementation AddFriendsTableViewCell

@synthesize profileImage = profileImage_;
@synthesize profileName = profileName_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

		self.contentView.backgroundColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1];
		
		profileImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 48, 48)];
		profileImage_.image = [UIImage imageNamed:@"sm_no_image.png"];
		profileImage_.layer.cornerRadius = 5;
		[self addSubview:profileImage_];
		
		profileName_ = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, 200, 25)];
		profileName_.backgroundColor = [UIColor clearColor];
		profileName_.font = FILTERFONT(16);
		profileName_.textColor = [UIColor colorWithRed:0.97 green:0.96 blue:0.96 alpha:1];		
		[self addSubview:profileName_];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
