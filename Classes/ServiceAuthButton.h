//
//  ServiceAuthButton.h
//  TheFilter
//
//  Created by John Thomas on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	
	ServiceAuthorize,
	ServiceDeauthorize
	
} ServiceAuthenticationMode;

@interface ServiceAuthButton : UIButton {

	NSString *serviceId_;
	ServiceAuthenticationMode authMode_;	
}

@property (nonatomic, retain) NSString *serviceId;
@property (nonatomic, assign) ServiceAuthenticationMode authMode;

@end
