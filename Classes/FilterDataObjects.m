//
//  FilterDataObjects.m
//  TheFilter
//
//  Created by Ben Hine on 2/8/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "FilterDataObjects.h"

#pragma mark FilterDataObject

#define SERVERDATEFORMATSTRING @"yyyy-MM-dd HH:mm:ss"

@implementation FilterDataObject


@synthesize lastUpdated = lastUpdated_;

-(id)initFromDictionary:(NSDictionary *)dict {
	
	self = [super init];
	if(self) {
		
		
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	
}


- (id)initWithCoder:(NSCoder *)decoder {
	
	self = [super init];
	if(self) {
		
		
	}
	
	return self;
	
}


@end

#pragma mark -
#pragma mark FilterTrack


@implementation FilterTrack

@synthesize trackID = trackID_;
@synthesize durationSeconds = durationSeconds_;
@synthesize urlString = urlString_;
@synthesize bitrate = bitrate_;
@synthesize trackTitle = trackTitle_;
@synthesize trackArtist = trackArtist_;
@synthesize trackAlbum = trackAlbum_;
@synthesize trackYear = trackYear_;
@synthesize trackFormat = trackFormat_;
@synthesize trackGenres = trackGenres_;

@synthesize trackBand = trackBand_;
@synthesize bandID = bandID_;

-(id)initFromDictionary:(NSDictionary*)dict {
	
	self = [super init];
	if(self) {
		
		trackID_ = [[dict objectForKey:@"id"] intValue];
		
		durationSeconds_ = [[NSNumber alloc] initWithInt:[[dict objectForKey:@"duration"] intValue]];
		//bitrate_ = [[NSNumber alloc] initWithInt:[[dict objectForKey:@"file_bitrate"] intValue]];
		
		trackTitle_ = [[NSString alloc] initWithString:[dict objectForKey:@"title"]];
		trackArtist_ = [[NSString alloc] initWithString:[dict objectForKey:@"artist"]];
		trackAlbum_ = [[NSString alloc] initWithString:[dict objectForKey:@"album"]];
		
		
		if ([dict objectForKey:@"year"] != [NSNull null]) {
			trackYear_ = [[NSString alloc] initWithFormat:@"%d", [[dict objectForKey:@"year"] intValue]];
		}
		
		/*
		if ([dict objectForKey:@"file_format"] != [NSNull null]) {
			trackFormat_ = [[NSString alloc] initWithString:[dict objectForKey:@"file_format"]];
		}*/
		/*
		if ([dict objectForKey:@"genre"] != [NSNull null]) {
			trackGenres_ = [[NSMutableArray alloc] init];
			NSDictionary *genreDict = [dict objectForKey:@"genre"];
			[trackGenres_ addObject:genreDict];
		}
		*/
		
		
		
		if([dict objectForKey:@"object_id"] && [dict objectForKey:@"object_id"] != [NSNull null]) {
			bandID_ = [[dict objectForKey:@"object_id"] intValue];
		}
		
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:SERVERDATEFORMATSTRING];
		lastUpdated_ = [[formatter dateFromString:[dict objectForKey:@"modified"]] retain];
		
		
		urlString_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL] ,[dict objectForKey:@"url"]];
		
	}
	
	return self;
}

@end

#pragma mark -
#pragma mark FilterBand

@implementation FilterBand

@synthesize bandID = bandID_;
@synthesize bandName = bandName_;
@synthesize bio = bio_;
@synthesize discography = discography_;
@synthesize members = members_;
@synthesize influences = influences_;
@synthesize bandLocation = bandLocation_;
@synthesize profilePicURL = profilePicURL_;
@synthesize profilePicLargeURL = profilePicLargeURL_;
@synthesize profilePicMediumURL = profilePicMediumURL_;
@synthesize profilePicSmallURL = profilePicSmallURL_;
@synthesize bandRating = bandRating_;
@synthesize followerCount = followerCount_;
@synthesize following = following_;
@synthesize genres = genres_;
@synthesize city = city_;

@synthesize trackArray = trackArray_;
@synthesize videosArray = videosArray_;

-(id)initFromDictionary:(NSDictionary*)dict {
	
	self = [super init];
	if(self) {
		
		bandID_ = [[dict objectForKey:@"id"] intValue];
		
		
		bandName_ = [[NSString alloc] initWithString:[dict objectForKey:@"name"]];
		if([dict objectForKey:@"bio"]) {
			bio_ = [[NSString alloc] initWithString:[dict objectForKey:@"bio"]];
		}
		if([dict objectForKey:@"discography"]) {
			discography_ = [[NSString alloc] initWithString:[dict objectForKey:@"discography"]];
		}
		if([dict objectForKey:@"members"]) {
			members_ = [[NSString alloc] initWithString:[dict objectForKey:@"members"]];
		}
		if([dict objectForKey:@"influences"]) {
			influences_ = [[NSString alloc] initWithString:[dict objectForKey:@"influences"]];
		}
        if ([dict objectForKey:@"genres"] != [NSNull null]) {
            genres_ = [[NSString alloc] initWithString:[dict objectForKey:@"genres"]];
        }
        if([dict objectForKey:@"city"]) {
            city_ = [[NSString alloc] initWithString:[dict objectForKey:@"city"]];
        }
        if([dict objectForKey:@"rank"] != [NSNull null]) {
            bandRating_ = [[NSNumber alloc] initWithInt:[[dict objectForKey:@"rank"] intValue]];
        }
        else {
            bandRating_ = [[NSNumber alloc] initWithInt:0];
        }
		/*
		if ([dict objectForKey:@"latitude"] != [NSNull null] && [dict objectForKey:@"longitude"] != [NSNull null]) {
			
			CLLocationDegrees lat = [[dict objectForKey:@"latitude"] doubleValue];
			CLLocationDegrees lon = [[dict objectForKey:@"longitude"] doubleValue];
			bandLocation_ = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
		}
		 */
		
		followerCount_ = [[NSNumber alloc] initWithInt:[[dict objectForKey:@"follower_cnt"] intValue]];
		
		if([dict objectForKey:@"following"] && [dict objectForKey:@"following"] != [NSNull null]) {
			following_ = CFBooleanGetValue((CFBooleanRef)[dict objectForKey:@"following"]);
		}
        
        if ([dict objectForKey:@"location"] != [NSNull null]) {
            locationName_ = [dict objectForKey:@"location"];
        }
		
		//bandRating_ = [[NSNumber alloc] initWithDouble:[[dict objectForKey:@"rating_score"] doubleValue] / 10.0];
		
		/*
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:SERVERDATEFORMATSTRING];
		lastUpdated_ = [[formatter dateFromString:[dict objectForKey:@"modified"]] retain];
		 */
		 
		if ([dict objectForKey:@"profile_picture"] != [NSNull null]) {
			profilePicURL_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL]  ,[dict objectForKey:@"profile_picture"]];
		}
        if ([dict objectForKey:@"profile_picture_large"] != [NSNull null]) {
			profilePicLargeURL_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL]  ,[dict objectForKey:@"profile_picture_large"]];
		}
        if ([dict objectForKey:@"profile_picture_medium"] != [NSNull null]) {
			profilePicMediumURL_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL]  ,[dict objectForKey:@"profile_picture_medium"]];
		}
        if ([dict objectForKey:@"profile_picture_small"] != [NSNull null]) {
			profilePicSmallURL_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL]  ,[dict objectForKey:@"profile_picture_small"]];
		}
		
		
		if([dict objectForKey:@"tracks"]) {
			trackArray_ = [[NSMutableArray alloc] init];
			for(NSDictionary *aDict in [dict objectForKey:@"tracks"]) {
				FilterTrack *track = [[FilterTrack alloc] initFromDictionary:aDict];
				[trackArray_ addObject:track];
				[track release];
			}
		}
		
//        if([dict objectForKey:@"youtube_links"]) {
//            videosArray_ = [[NSMutableArray alloc] init];
//            
//            [videosArray_ addObjectsFromArray:[dict objectForKey:@"youtube_links"]];
//        }
    }
	return self;
}

@end

#pragma mark-
#pragma mark FilterVideo
@implementation FilterVideo

@synthesize title = title_;
@synthesize url = url_;
@synthesize durationSeconds = durationSeconds_;
@synthesize thumbnail = thumbnail_;
@synthesize id = id_;

- (id)initFromDictionary:(NSDictionary *)dict {
    self = [super init];
    
    if (self) {
    
        if ([dict objectForKey:@"title"]) {
            title_ = [[dict objectForKey:@"title"] retain];
        }
        if ([dict objectForKey:@"player"]) {
            NSDictionary *newDict = [NSDictionary dictionaryWithDictionary:[dict objectForKey:@"player"]];
            
            if ([newDict objectForKey:@"default"]) {
                url_ = [[newDict objectForKey:@"default"] retain];
            }
        }
        if ([dict objectForKey:@"duration"]) {
            durationSeconds_ = [[NSNumber alloc] initWithInt:[[dict objectForKey:@"duration"] intValue]];
        }
        if ([dict objectForKey:@"thumbnail"]) {
            NSDictionary *newDict = [NSDictionary dictionaryWithDictionary:[dict objectForKey:@"thumbnail"]];
            
            if ([newDict objectForKey:@"sqDefault"]) {
                thumbnail_ = [[newDict objectForKey:@"sqDefault"] retain];
            }
        }
        if ([dict objectForKey:@"id"]) {
            id_ = [[dict objectForKey:@"id"] retain];
        }
        
    }
    
    return self;
}

@end
                                          
#pragma mark -
#pragma mark FilterNews
@implementation FilterNews

@synthesize newsID = newsID_;
@synthesize title = title_;
@synthesize body = body_;
@synthesize urlString = urlString_;
@synthesize type = type_;
@synthesize referenceID = referenceID_;
@synthesize timestamp = timestamp_;

- (id)initFromDictionary:(NSDictionary *)dict {
	self = [super init];
	if (self) {
        
		newsID_ = [[dict objectForKey:@"id"] intValue];
		title_ = [[NSString alloc] initWithString:[dict objectForKey:@"title"]];
		body_ = [[NSString alloc] initWithString:[dict objectForKey:@"body"]];

        if ([dict objectForKey:@"image"] != [NSNull null]) {
			
			
			urlString_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL] ,[dict objectForKey:@"image"]];
            
		}
        
		type_ = [[dict objectForKey:@"type"] intValue];
		referenceID_ = [[dict objectForKey:@"external_id"] intValue];

		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:SERVERDATEFORMATSTRING];
		timestamp_ = [[formatter dateFromString:[dict objectForKey:@"timestamp"]] retain];

	}
	return self;
}

@end

#pragma mark -
#pragma mark FilterGenre

@implementation FilterGenre

@synthesize genreID = genreID_;
@synthesize name = name_;

- (id)initFromDictionary:(NSDictionary *)dict {
	self = [super init];
	if (self) {
		name_ = [[NSString alloc] initWithString:[dict objectForKey:@"name"]];
		genreID_ = [[dict objectForKey:@"id"] intValue];
        
	}
	return self;
}

@end

#pragma mark -
#pragma mark FilterVenue


@implementation FilterVenue

@synthesize venueID = venueID_;
@synthesize phoneNumber = phoneNumber_;
@synthesize addressOne = addressOne_;
@synthesize addressTwo = addressTwo_;
@synthesize city = city_;
@synthesize venueState = state_;
@synthesize zip = zip_;
@synthesize description = description_;
@synthesize venueLocation = venueLocation_;
@synthesize venueName = venueName_;
@synthesize webURL = webURL_;
@synthesize numberOfShows = numberOfShows_;
@synthesize futureShows = futureShows_;
@synthesize pastShows = pastShows_;

-(id)initFromDictionary:(NSDictionary*)dict {
	
	self = [super init];
	if(self) {
		
		venueID_ = [[dict objectForKey:@"id"] intValue];
		venueName_ = [[dict objectForKey:@"name"] retain];
		
		if ([dict objectForKey:@"latitude"] != [NSNull null] && [dict objectForKey:@"longitude"] != [NSNull null]) {

			CLLocationDegrees lat = [[dict objectForKey:@"latitude"] doubleValue];
			CLLocationDegrees lon = [[dict objectForKey:@"longitude"] doubleValue];
			venueLocation_ = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
		}	
		
		description_ = [[dict objectForKey:@"description"] retain];
		webURL_ = [[dict objectForKey:@"website"] retain];
		addressOne_ = [[dict objectForKey:@"address_0"] retain];
		addressTwo_ = [[dict objectForKey:@"address_1"] retain];
		city_ = [[dict objectForKey:@"city"] retain];
		state_ = [[dict objectForKey:@"state"] retain];
		zip_ = [[dict objectForKey:@"zipcode"] retain];
		numberOfShows_ = [[dict objectForKey:@"show_count"] retain];
        futureShows_ = [[dict objectForKey:@"future_show_count"] retain];
        pastShows_ = [[dict objectForKey:@"past_show_count"] retain];
		phoneNumber_ = [[dict objectForKey:@"phone"] retain];
		
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:SERVERDATEFORMATSTRING];
		lastUpdated_ = [[formatter dateFromString:[dict objectForKey:@"modified"]] retain];
		
	}
	return self;	
}

@end

#pragma mark -
#pragma mark FilterShow


@implementation FilterShow

@synthesize showID = showID_;
@synthesize agePolicy = agePolicy_;
@synthesize showBands = showBands_;
@synthesize startDate = startDate_;
@synthesize endDate = endDate_;
@synthesize price = price_;
@synthesize showVenue = showVenue_;
@synthesize showLocation = showLocation_;
@synthesize name = name_;
@synthesize attendingCount = attendingCount_;
@synthesize attending = attending_;
@synthesize checkedIn = checkedIn_;

@synthesize posterURL = posterURL_;
@synthesize posterLargeURL = posterLargeURL_;
@synthesize posterFullURL = posterFullURL_;
@synthesize posterMediumURL = posterMediumURL_;

-(id)initFromDictionary:(NSDictionary*)dict {
	
	self = [super init];
	if(self) {
		
		//TODO: set properties based on return values from API
		showID_ = [[dict objectForKey:@"id"] intValue];
        
        //JDH FIX
		NSString *testString;
		
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:SERVERDATEFORMATSTRING];
		lastUpdated_ = [[formatter dateFromString:[dict objectForKey:@"modified"]] retain];
		
		startDate_ = [[formatter dateFromString:[dict objectForKey:@"start_time"]] retain];
		endDate_ = [[formatter dateFromString:[dict objectForKey:@"end_time"]] retain];
		
		if ([dict objectForKey:@"latitude"] && [dict objectForKey:@"longitude"]) {
			showLocation_ = [[CLLocation alloc] initWithLatitude:[[dict objectForKey:@"latitude"] doubleValue] longitude:[[dict objectForKey:@"longitude"] doubleValue]];
		}
			
		if ([dict objectForKey:@"poster"] != [NSNull null] ) {
            // JDH FIX
            testString = [dict objectForKey:@"poster"];
            if ([testString length] > 0){
                posterURL_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL] , [dict objectForKey:@"poster"]];
            }
            else {
                 //posterURL_ = (NSString *)[NSNull null];
                posterURL_ = nil;
            }
         //   NSLog(@"posterobject= %@",[dict objectForKey:@"poster"]);
            
		}

   		if ([dict objectForKey:@"poster_large"] != [NSNull null]) {
            // JDH FIX
            testString = [dict objectForKey:@"poster_large"];
            if ([testString length] > 0){
                posterLargeURL_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL] , [dict objectForKey:@"poster_large"]];
            }
            else {
                //posterLargeURL_ = (NSString *)[NSNull null];
                posterLargeURL_ = nil;
            }
		}
        if ([dict objectForKey:@"poster_medium"] != [NSNull null]) {
            // JDH FIX
            testString = [dict objectForKey:@"poster_medium"];
            if ([testString length] > 0){
                posterURL_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL] , [dict objectForKey:@"poster_medium"]];
            }
            else {
                //posterURL_ = (NSString *)[NSNull null];
                posterURL_ = nil;
            }
		}
        
   		if ([dict objectForKey:@"poster_full"] != [NSNull null]) {
            // JDH FIX
            testString = [dict objectForKey:@"poster_full"];
            if ([testString length] > 0){
                posterLargeURL_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL] , [dict objectForKey:@"poster_full"]];
            }
            else {
                //posterLargeURL_ = (NSString *)[NSNull null];
                posterLargeURL_ = nil;
            }
		}
        
        if([dict objectForKey:@"name"]) {
            name_ = [[NSString alloc] initWithString:[dict objectForKey:@"name"]];
        }
        if([dict objectForKey:@"attending_cnt"]) {
            attendingCount_ = [[NSNumber alloc] initWithInt:[[dict objectForKey:@"attending_cnt"] intValue]];
        }
        if([dict objectForKey:@"attending"]) {
            attending_ = [[dict objectForKey:@"attending"] boolValue];
        }
        if([dict objectForKey:@"checked_in"]) {
            checkedIn_ = [[dict objectForKey:@"checked_in"] boolValue];
        }
		/* if (posterURL_ == nil) 	{ 
			posterURL_ = @"http://placekitten.com/169/261/";
			//posterURL_ = @"http://placehold.it/169x261";
		}
		 */
        // JDH
        // NSLog(@"FilterDataObjects posterURL= %@", posterURL_);
		
		price_ = [[NSString alloc] initWithString:[dict objectForKey:@"price"]];
		
		
		if ([dict objectForKey:@"venue"]) {
			showVenue_ = [[FilterVenue alloc] initFromDictionary:[dict objectForKey:@"venue"]];
		}
		
        showBands_ = [[NSMutableArray alloc] init];
        
        for(NSDictionary *aDict in [dict objectForKey:@"lineup"]) {
            [showBands_ addObject:aDict];
        }
        		
	}
	return self;
}

@end


#pragma mark -
#pragma mark FilterCheckin


@implementation FilterCheckin

@synthesize checkinID = checkinID_;
@synthesize checkinShowID = checkinShowID_;
@synthesize checkinComment = checkinComment_;
@synthesize checkinDate = checkinDate_;
@synthesize object = object_;
@synthesize checkinLocation = checkinLocation_;
@synthesize checkinShowName = checkinShowName_;
@synthesize checkinPoster = checkinPoster_;
@synthesize bookmarked = bookmarked_;

-(id)initFromDictionary:(NSDictionary*)dict {
	
	self = [super init];
	if(self) {
		
		//TODO: set properties based on return values from API
		checkinID_ = [[dict objectForKey:@"id"] intValue];
		
        checkinComment_ = [[NSString alloc] initWithString:[dict objectForKey:@"comment"]];
        
		if ([dict objectForKey:@"latitude"] && [dict objectForKey:@"longitude"]) {
			checkinLocation_ = [[CLLocation alloc] initWithLatitude:[[dict objectForKey:@"latitude"] doubleValue] longitude:[[dict objectForKey:@"longitude"] doubleValue]];
		}
        
		if([dict objectForKey:@"show"] && [dict objectForKey:@"show"] != [NSNull null]) {
            NSDictionary *showsDict = [dict objectForKey:@"show"];
            checkinShowID_ = [[showsDict objectForKey:@"id"] intValue];
            checkinShowName_ = [showsDict objectForKey:@"name"];
            bookmarked_ = [[showsDict objectForKey:@"attending"] boolValue];
            if ([showsDict objectForKey:@"poster"] != [NSNull null]) {
                checkinPoster_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL] , [showsDict objectForKey:@"poster"]];
            }
		}
        
	}
	return self;
}

@end


@implementation FilterFanAccount

@synthesize accountID = accountID_;
@synthesize userLocation = userLocation_;
@synthesize userName = userName_;
@synthesize userZip = userZip_;
@synthesize profilePicURL = profilePicURL_;
@synthesize isSelf = isSelf_;
@synthesize showsLoaded = showsLoaded_;
@synthesize bandsLoaded = bandsLoaded_;
@synthesize checkinsLoaded = checkinsLoaded_;
@synthesize userPass = userPass_;

@synthesize bandsCount = bandsCount_, checkinsCount = checkinsCount_, showsCount = showsCount_;


+(id)getMyAccountWithRequester:(id<FilterAPIOperationDelegate>)sender {
	
	//TODO: check cache for account object and return it if it exists\ is fresh
	
    [[FilterAPIOperationQueue sharedInstance] FilterAPIRequestWithParams:nil andType:kFilterAPITypeAccountDetails andCallback:sender];
	
	return nil;
}


-(id)initFromDictionary:(NSDictionary*)dict {
	
	self = [super init];
	if(self) {
		/*
		if ([dict objectForKey:@"user"] != [NSNull null]) {
			NSDictionary *userDict = [dict objectForKey:@"user"];
			if([userDict objectForKey:@"id"]) {
				accountID_ = [[userDict objectForKey:@"id"] intValue];
			}			
		}
		*/
		
		/*
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:SERVERDATEFORMATSTRING];
		lastUpdated_ = [[formatter dateFromString:[dict objectForKey:@"modified"]] retain];
		*/
		 
		//if ([dict objectForKey:@"latitude"] != [NSNull null] && [dict objectForKey:@"longitude"] != [NSNull null])
		//	userLocation_ = [[CLLocation alloc] initWithLatitude:[[dict objectForKey:@"latitude"] doubleValue] longitude:[[dict objectForKey:@"longitude"] doubleValue]];
		
		userName_ = [[NSString alloc] initWithString:[dict objectForKey:@"username"]];
		
		//userZip_ = [[NSString alloc] initWithFormat:@"", [[dict objectForKey:@"zipcode"] intValue]];
		
		
		if([dict objectForKey:@"profile_picture"] != [NSNull null] && [dict objectForKey:@"profile_picture"]) {
			profilePicURL_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL] , [dict objectForKey:@"profile_picture"]];
        } 

		
		bandsCount_ = [[dict objectForKey:@"band_count"] intValue];
		checkinsCount_ = [[dict objectForKey:@"checkin_count"] intValue];
		showsCount_ = [[dict objectForKey:@"upcoming_show_count"] intValue];
		
		showsLoaded_ = NO;
		bandsLoaded_ = NO;
		checkinsLoaded_ = NO;
    
	}
	return self;
}

@end


@implementation FilterUserAccount

@synthesize userName = userName_;
@synthesize userZip = userZip_;
@synthesize profilePicURL = profilePicURL_;
@synthesize userEmail = userEmail_;
@synthesize userGender = userGender_;
@synthesize dateOfBirth = dateOfBirth_;

-(id)initFromDictionary:(NSDictionary*)dict {
	
	self = [super init];
	if(self) {
		
        if([dict objectForKey:@"username"]) {
            userName_ = [[NSString alloc] initWithString:[dict objectForKey:@"username"]];
        }
        
        if([dict objectForKey:@"dob"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            
            dateOfBirth_ = [formatter dateFromString:[dict objectForKey:@"dob"]];
            [formatter release];
        }
		
        if([dict objectForKey:@"email"]) {
            userEmail_ = [[NSString alloc] initWithString:[dict objectForKey:@"email"]];
        }
        
        if([dict objectForKey:@"zipcode"]) {
            userZip_ = [[NSString alloc] initWithString:[dict objectForKey:@"zipcode"]];
        }
        
        if([dict objectForKey:@"gender"] && [[dict objectForKey:@"gender"] objectForKey:@"name"]) {
            userGender_ = [[NSString alloc] initWithString:[[dict objectForKey:@"gender"] objectForKey:@"name"]];
        }
		
		if([dict objectForKey:@"profile_picture"] != [NSNull null] && [dict objectForKey:@"profile_picture"]) {
			profilePicURL_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL] , [dict objectForKey:@"profile_picture"]];
		} 

	}
	return self;
}

@end



@implementation FilterFeaturedBand

@synthesize featuredBand = featuredBand_;
@synthesize featuredShows = featuredShows_;
@synthesize featuredTracks = featuredTracks_;

-(id)initFromDictionary:(NSDictionary*)dict {

	self = [super init];
	if(self) {
		
		if ([dict objectForKey:@"band"] != [NSNull null]) {
			featuredBand_ = [[FilterBand alloc] initFromDictionary:[dict objectForKey:@"band"]];
		}
		
		if ([dict objectForKey:@"shows"] != [NSNull null]) {
			featuredShows_ = [[NSMutableArray alloc] init];	
			NSArray *showsList = [dict objectForKey:@"shows"];
			for (NSDictionary *showDict in showsList) {
				FilterShow *show = [[FilterShow alloc] initFromDictionary:showDict];
				[featuredShows_ addObject:show];
                
                [show release];
			}
		}
		
		if ([dict objectForKey:@"tracks"] != [NSNull null]) {
			featuredTracks_ = [[NSMutableArray alloc] init];	
			NSArray *tracksList = [dict objectForKey:@"tracks"];
			for (NSDictionary *trackDict in tracksList) {
				FilterTrack *track = [[FilterTrack alloc] initFromDictionary:trackDict];
				[featuredTracks_ addObject:track];
                
                [track release];
			}
		}
	}
	
	return self;
}

@end


@implementation FilterPaginator

@synthesize currentPage = currentPage_;
@synthesize hasNext = hasNext_;
@synthesize hasPrev = hasPrev_;
@synthesize totalPages = totalPages_;
@synthesize perPage = perPage_;
@synthesize totalObjects = totalObjects_;

-(id)initFromDictionary:(NSDictionary*)dict {
	self = [super init];
	if(self) {
		
		currentPage_ = [[dict objectForKey:@"current_page"] intValue];
		hasNext_ = CFBooleanGetValue((CFBooleanRef)[dict objectForKey:@"has_next"]);
		hasPrev_ = CFBooleanGetValue((CFBooleanRef)[dict objectForKey:@"has_previous"]);
		totalPages_ = [[dict objectForKey:@"num_pages"] intValue];
		perPage_ = [[dict objectForKey:@"objects_per_page"] intValue];
		totalObjects_ = [[dict objectForKey:@"total_objects"] intValue];
		
	}
	return self;
}

@end



#pragma mark -
#pragma mark FilterAccountShow


@implementation FilterAccountShow

@synthesize showID = showID_;
@synthesize attending = attending_;
@synthesize showName = showName_;
@synthesize showPoster = showPoster_;

-(id)initFromDictionary:(NSDictionary*)dict {
	
	self = [super init];
	if(self) {
		
		showID_ = [[dict objectForKey:@"id"] intValue];
		attending_ = [[dict objectForKey:@"attending"] boolValue];
        
        showName_ = [[NSString alloc] initWithString:[dict objectForKey:@"name"]];
        
		if ([dict objectForKey:@"poster"] != [NSNull null]) {
            showPoster_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL] , [dict objectForKey:@"poster"]];
		}
	}
	return self;
}

@end



#pragma mark -
#pragma mark FilterAccountBand


@implementation FilterAccountBand

@synthesize bandID = bandID_;
@synthesize following = following_;
@synthesize bandName = bandName_;
@synthesize bandPoster = bandPoster_;
@synthesize genres = genres_;
@synthesize city = city_;

-(id)initFromDictionary:(NSDictionary*)dict {
	
	self = [super init];
	if(self) {
		
		bandID_ = [[dict objectForKey:@"id"] intValue];
		following_ = [[dict objectForKey:@"following"] boolValue];
        
        bandName_ = [[NSString alloc] initWithString:[dict objectForKey:@"name"]];
        genres_ = [[NSString alloc] initWithString:[dict objectForKey:@"genres"]];
        city_ = [[NSString alloc] initWithString:[dict objectForKey:@"city"]];
        
		if ([dict objectForKey:@"profile_picture"] != [NSNull null]) {
            bandPoster_ = [[NSString alloc] initWithFormat:@"%@%@",[[FilterAPIOperationQueue sharedInstance] API_MEDIA_URL] , [dict objectForKey:@"profile_picture"]];
		}
	}
	return self;
}

@end
