//
//  FilterDataObjects.h
//  TheFilter
//
//  Created by Ben Hine on 2/8/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Common.h"
#import "FilterAPIOperationQueue.h"

@interface FilterDataObject : NSObject <NSCoding> {
    NSDate *lastUpdated_;
}

-(id)initFromDictionary:(NSDictionary*)dict;

@property (nonatomic, retain) NSDate *lastUpdated;

@end


//---------------------------------------------------
@class FilterBand;

@interface FilterTrack : FilterDataObject <NSCoding> {

	NSInteger trackID_;
	NSNumber *durationSeconds_, *bitrate_;
	NSString *urlString_;
	NSString *trackTitle_, *trackArtist_, *trackAlbum_, *trackYear_, *trackFormat_;
	NSMutableArray *trackGenres_;
	
	NSInteger bandID_;
	FilterBand *trackBand_;

}

@property (nonatomic, assign) NSInteger trackID;
@property (nonatomic, retain) NSNumber *durationSeconds, *bitrate;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *trackTitle, *trackArtist, *trackAlbum, *trackYear, *trackFormat;
@property (nonatomic, retain) NSMutableArray *trackGenres;

@property (nonatomic, assign) NSInteger bandID;
@property (nonatomic, retain) FilterBand *trackBand;

@end

//---------------------------------------------------


@interface FilterNews : FilterDataObject <NSCoding> {
    
	NSInteger newsID_;
    NSString *title_;
    NSString *body_;
    NSString *urlString;
    NSInteger type_;
    NSInteger referenceID_;
    NSDate *timestamp_;
	
    
}

@property (nonatomic, assign) NSInteger newsID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger referenceID;
@property (nonatomic, retain) NSDate *timestamp;

@end


//---------------------------------------------------


@interface FilterGenre : FilterDataObject <NSCoding> {
	
	NSInteger genreID_;
	NSString *name_;
    
	
}

@property (nonatomic, assign) NSInteger genreID;
@property (nonatomic, retain) NSString *name;

@end


//---------------------------------------------------


@interface FilterVideo : FilterDataObject <NSCoding> {
	
	NSString *title_;
    NSString *url_;
    NSNumber *durationSeconds_;
    NSString *thumbnail_;
    NSString *id_;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSNumber *durationSeconds;
@property (nonatomic, retain) NSString *thumbnail;
@property (nonatomic, retain) NSString *id;         //Added JDH Sept 2013

@end


//---------------------------------------------------

@interface FilterBand : FilterDataObject <NSCoding> {

	NSInteger bandID_;
	
	NSString *bandName_;
	
	
	NSNumber *followerCount_;
	BOOL following_;
	
	NSString *genres_;
    
	NSString *influences_, *discography_, *members_, *bio_;
	
	CLLocation *bandLocation_;
    
    NSString *locationName_;
	
    NSString *city_;
    
	NSString *profilePicURL_;
	NSString *profilePicLargeURL_;
    NSString *profilePicMediumURL_;
    NSString *profilePicSmallURL_;

	NSNumber *bandRating_;
	
    NSMutableArray *videosArray_;
	
	NSMutableArray *trackArray_;
	
}

@property (nonatomic, assign) NSInteger bandID;
@property (nonatomic, retain) NSString *bandName;
@property (nonatomic, retain) NSString *profilePicURL;
@property (nonatomic, retain) NSString *profilePicLargeURL;
@property (nonatomic, retain) NSString *profilePicMediumURL;
@property (nonatomic, retain) NSString *profilePicSmallURL;
@property (nonatomic, retain) NSNumber *bandRating;
@property (nonatomic, retain) NSString *influences, *discography, *members, *bio;
@property (nonatomic, retain) CLLocation *bandLocation;
@property (nonatomic, retain) NSNumber *followerCount;
@property (nonatomic, assign) BOOL following;
@property (nonatomic, retain) NSString *genres;
@property (nonatomic, retain) NSString *city;

@property (nonatomic, retain) NSMutableArray *videosArray;
@property (nonatomic, retain) NSMutableArray *trackArray;


@end


//---------------------------------------------------

@interface FilterVenue : FilterDataObject <NSCoding> {
	
	
	NSInteger venueID_;
    NSNumber *numberOfShows_;
    NSNumber *futureShows_;
    NSNumber *pastShows_;
	
	NSString *phoneNumber_,*addressOne_,*addressTwo_,*city_,*state_,*zip_,*description_, *venueName_, *webURL_;
	
	CLLocation *venueLocation_;
}

@property (nonatomic, retain) NSString *phoneNumber,*addressOne,*addressTwo,*city,*venueState,*zip,*description, *venueName;
@property (nonatomic, retain) NSNumber *futureShows;
@property (nonatomic, retain) NSNumber *pastShows;
@property (nonatomic, assign) NSInteger venueID;
@property (nonatomic, retain) CLLocation *venueLocation;
@property (nonatomic, retain) NSString *webURL;
@property (nonatomic, retain) NSNumber *numberOfShows;

@end

//---------------------------------------------------


@interface FilterShow : FilterDataObject <NSCoding> {

	NSInteger showID_;
	
	NSString *agePolicy_;
	
	NSString *posterURL_;
	NSString *posterLargeURL_;
    NSString *posterFullURL_;
    NSString *posterMediumURL_;
	NSMutableArray *showBands_;
	NSDate *startDate_, *endDate_;
	NSString *price_;
	NSString *name_;
    NSNumber *attendingCount_;
    BOOL attending_;
    BOOL checkedIn_;
	FilterVenue *showVenue_;
	
	NSString *webURL_;
	
	
	CLLocation *showLocation_;

}

@property (nonatomic, assign) NSInteger showID;

@property (nonatomic, assign) BOOL attending;
@property (nonatomic, assign) BOOL checkedIn;
@property (nonatomic, retain) NSString *agePolicy;
@property (nonatomic, retain) NSArray *showBands;
@property (nonatomic, retain) NSDate *startDate, *endDate;
@property (nonatomic, retain) NSString *price;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *attendingCount;
@property (nonatomic, retain) FilterVenue *showVenue;
@property (nonatomic, retain) CLLocation *showLocation;
@property (nonatomic, retain) NSString *posterURL;
@property (nonatomic, retain) NSString *posterLargeURL;
@property (nonatomic, retain) NSString *posterFullURL;
@property (nonatomic, retain) NSString *posterMediumURL;


@end







//---------------------------------------------------



@interface FilterCheckin : FilterDataObject <NSCoding> {

	NSInteger checkinID_;
	NSInteger checkinShowID_;
	
	NSString *checkinComment_;
	NSString *checkinShowName_;
    NSString *checkinPoster_;
    BOOL bookmarked_;
	
	NSDate *checkinDate_;
	
	//This is either a show or a venue
	FilterShow *object_;
	
	CLLocation *checkinLocation_;
	

}

@property (nonatomic, assign) NSInteger checkinID;
@property (nonatomic, assign) NSInteger checkinShowID;

@property (nonatomic, retain) NSString *checkinComment;
@property (nonatomic, retain) NSString *checkinShowName;
@property (nonatomic, retain) NSString *checkinPoster;
@property (nonatomic, assign) BOOL bookmarked;

@property (nonatomic, retain) NSDate *checkinDate;

@property (nonatomic, retain) FilterShow *object;
@property (nonatomic, retain) CLLocation *checkinLocation;


@end


//---------------------------------------------------


@interface FilterFanAccount : FilterDataObject <NSCoding> {
	
	NSInteger accountID_;
	
	CLLocation *userLocation_;
	
	NSString *userName_;
	
	NSString *userPass_;
	
	NSString *userZip_;
	
	NSString *profilePicURL_;
	
	BOOL isSelf_;
	BOOL showsLoaded_;
	BOOL bandsLoaded_;
	BOOL checkinsLoaded_;
	
	
	NSInteger showsCount_, bandsCount_, checkinsCount_;
	
	NSMutableArray *showsArray_;
	NSMutableArray *bandsArray_;
	NSMutableArray *checkinsArray_;
	
}

@property (nonatomic, assign) NSInteger accountID;
@property (nonatomic, retain) CLLocation *userLocation;
@property (nonatomic, retain) NSString *userName, *userZip, *profilePicURL, *userPass;
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, assign) NSInteger showsCount, bandsCount, checkinsCount;

@property (nonatomic, assign) BOOL showsLoaded,bandsLoaded,checkinsLoaded;

+(id)getMyAccountWithRequester:(id<FilterAPIOperationDelegate>)sender;


@end

//---------------------------------------------------


@interface FilterUserAccount : FilterDataObject <NSCoding> {
	
	NSString *userName_;
	
	NSString *userZip_;
	
	NSString *profilePicURL_;
    
    NSDate *dateOfBirth_;
    
    NSString *userGender_;
    
    NSString *userEmail_;
	
}

@property (nonatomic, retain) NSDate *dateOfBirth;
@property (nonatomic, retain) NSString *userName, *userZip, *profilePicURL, *userGender, *userEmail;

@end

//-------------------------------------------------------

@interface FilterFeaturedBand : FilterDataObject <NSCoding>
{
	FilterBand *featuredBand_;
	
	NSMutableArray *featuredShows_;
	NSMutableArray *featuredTracks_;
}

@property (nonatomic, retain) FilterBand *featuredBand;
@property (nonatomic, retain) NSMutableArray *featuredShows;
@property (nonatomic, retain) NSMutableArray *featuredTracks;

@end

@interface FilterPaginator : FilterDataObject <NSCoding> 
{
	
	NSInteger currentPage_;
	BOOL hasNext_;
	BOOL hasPrev_;
	NSInteger totalPages_;
	NSInteger perPage_;
	NSInteger totalObjects_;
	
}

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL hasNext;
@property (nonatomic, assign) BOOL hasPrev;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger perPage;
@property (nonatomic, assign) NSInteger totalObjects;


@end


//---------------------------------------------------



@interface FilterAccountShow : FilterDataObject <NSCoding> {
    
	NSInteger showID_;
    BOOL attending_;
	
	NSString *showName_;
    NSString *poster_;
    
}

@property (nonatomic, assign) NSInteger showID;
@property (nonatomic, assign) BOOL attending;

@property (nonatomic, retain) NSString *showName;
@property (nonatomic, retain) NSString *showPoster;

@end


//---------------------------------------------------



@interface FilterAccountBand : FilterDataObject <NSCoding> {
    
	NSInteger bandID_;
    BOOL following_;
	
	NSString *bandName_;
    NSString *bandPoster_;
	NSString *genres_;
    NSString *city_;
    
}

@property (nonatomic, assign) NSInteger bandID;
@property (nonatomic, assign) BOOL following;

@property (nonatomic, retain) NSString *bandName;
@property (nonatomic, retain) NSString *bandPoster;
@property (nonatomic, retain) NSString *genres;
@property (nonatomic, retain) NSString *city;

@end
