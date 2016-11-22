//
//  Errors.h
//  TheFilter
//
//  Created by Ben Hine on 1/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#define ErrorWasOfType(a,b) \
((a.code-a.code%1000)==b)

#import "StreamingAudioDriverErrors.h"
#import "FileDownloadErrors.h"
