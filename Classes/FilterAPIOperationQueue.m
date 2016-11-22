//
//  FilterAPIOperationQueue.m
//  TheFilter
//
//  Created by Ben Hine on 1/27/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import "FilterAPIOperationQueue.h"
#import "FilterDataObjects.h"
#import "JSON.h"
#import "SFHFKeychainUtils.h"
#import "FilterLocationManager.h"
#import "FilterView.h"

#define kTIMEOUT 40

@interface FilterAPIOperationQueue()

- (ASIHTTPRequest *)createBaseRequestWithURL:(NSString *)urlString andType:(FilterAPIType)type withCallback:(id<FilterAPIOperationDelegate>)callback;
- (void)getWithRequest:(ASIHTTPRequest *)request;
- (void)deleteWithRequest:(ASIHTTPRequest *)request;
- (void)postWithRequest:(ASIHTTPRequest *)request andOptions:(id)options;
- (id)parseResults:(id)results withType:(FilterAPIType)type error:(NSError**)err;
- (id)parseMetadata:(id)results error:(NSError**)err;

- (void)removeNilEntries:(NSDictionary*)dict;

@end

@implementation FilterAPIOperationQueue

@synthesize API_URL, API_MEDIA_URL;

#pragma mark -
#pragma mark private methods

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

int encode(unsigned s_len, char *src, unsigned d_len, char *dst)
{
	unsigned triad;
	
	for (triad = 0; triad < s_len; triad += 3)
	{
		unsigned long int sr;
		unsigned byte;
		
		for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte)
		{
			sr <<= 8;
			sr |= (*(src+triad+byte) & 0xff);
		}
		
		sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
		
		if (d_len < 4) return 1; /* error - dest too short */
		
		*(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
		switch(byte)
		{
			case 3:
				*(dst+3) = base64[sr&0x3f];
				sr >>= 6;
			case 2:
				*(dst+2) = base64[sr&0x3f];
				sr >>= 6;
			case 1:
				*(dst+1) = base64[sr&0x3f];
				sr >>= 6;
				*(dst+0) = base64[sr&0x3f];
		}
		dst += 4; d_len -= 4;
	}
	
	return 0;
	
}

- (ASIHTTPRequest *)createBaseRequestWithURL:(NSString *)urlString andType:(FilterAPIType)type withCallback:(id<FilterAPIOperationDelegate>)callback {
    
    NSURL *url                  = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest *request     = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds      = kTIMEOUT;
    request.cachePolicy         = ASIUseDefaultCachePolicy;
    request.userInfo            = [NSDictionary dictionaryWithObject:callback forKey:@"callback"];
    request.type                = type;
    request.delegate            = self;
    request.didFinishSelector   = @selector(requestDone:);
    request.didFailSelector     = @selector(requestWentWrong:);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY]) {
        NSString *user  = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY];
		NSError *err    = nil;
		NSString *pass  = [SFHFKeychainUtils getPasswordForUsername:user andServiceName:KEYCHAIN_SERVICENAME error:&err];
		
		if([pass length] > 0) {
            
			NSData *dataStr = [[NSString stringWithFormat:@"%@:%@",user, pass] dataUsingEncoding:NSUTF8StringEncoding];
			char encodeArr[512];
			memset(encodeArr, '\0',sizeof(encodeArr));
			encode([dataStr length],(char*)[dataStr bytes],sizeof(encodeArr),encodeArr);
            
            NSString *authString = [NSString stringWithFormat:@"Basic %@", [NSString stringWithCString:encodeArr encoding:NSUTF8StringEncoding]];
            [request addRequestHeader:@"Authorization" value:authString];
		}
    }
    
    // DEBUG
   // NSLog(@"%@", [[request requestHeaders] description]);
  //  NSLog(@"%@", [[[NSString alloc] initWithData:[request postBody] encoding:4] autorelease]);
   // NSLog(@"debug URL: %@", urlString);
    
    return request;
}

- (void)getWithRequest:(ASIHTTPRequest *)request {
    [self addOperation:request];
}


- (void)deleteWithRequest:(ASIHTTPRequest *)request {
    
    [request setRequestMethod:@"DELETE"];
    
    [self addOperation:request];
}

- (void)postWithRequest:(ASIHTTPRequest *)request andOptions:(id)options {
    
	//TODO: fix this later - it need support for images and support for empty bodies
    
	NSString *params;
    
	SBJsonWriter *json = [[SBJsonWriter alloc] init];
    
	if([options isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)options;
		params = [json stringWithObject:dict];
	} else if ([options isKindOfClass:[NSArray class]]) {
		NSArray *array = (NSArray*)options;
		params = [json stringWithObject:array];
	}
	[json release];
	
	
	NSMutableData *requestData = nil;
	BOOL multipart = NO;
	if([options isKindOfClass:[NSString class]]) {
		requestData = [NSMutableData dataWithData:[options dataUsingEncoding:NSUTF8StringEncoding]];
	} else if([options isKindOfClass:[NSData class]]) {
		requestData = [NSMutableData dataWithData:options];;	// for now this is only used in image uploads... this may need to change in the future
        multipart = YES;
	} else {
		requestData = [NSMutableData dataWithData:[params dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[request setPostBody:requestData];
	
    if (multipart == NO) {	
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
    } else {
        [request addRequestHeader:@"Content-Type" value:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",@"q1w2e3r4t5y6u7i8o91234"]];
    }
	
    [self addOperation:request];
}

-(NSData *)dataForPOSTWithDictionary:(NSDictionary *)aDictionary boundary:(NSString *)aBoundary {
    NSArray *myDictKeys = [aDictionary allKeys];
    
    NSMutableData *formData = [NSMutableData dataWithCapacity:1];
    NSString *myBoundary = [NSString stringWithFormat:@"--%@\r\n", aBoundary];
    
    for(int i = 0;i < [myDictKeys count];i++) {
        id parameterKey = [aDictionary valueForKey:[myDictKeys objectAtIndex:i]];
        [formData appendData:[myBoundary dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([parameterKey isKindOfClass:[NSString class]]) {
            [formData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [myDictKeys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            [formData appendData:[[NSString stringWithFormat:@"%@", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        } else if ([parameterKey isKindOfClass:[NSNumber class]]) {
            
            [formData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [myDictKeys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            [formData appendData:[[NSString stringWithFormat:@"%@", [parameterKey stringValue]] dataUsingEncoding:NSUTF8StringEncoding]];
            
        } else if(([parameterKey isKindOfClass:[NSURL class]]) && ([parameterKey isFileURL])) {
            [formData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [myDictKeys objectAtIndex:i], [[parameterKey path] lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
            [formData appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [formData appendData:[NSData dataWithContentsOfFile:[parameterKey path]]];
        } else if(([parameterKey isKindOfClass:[NSData class]])) {
            [formData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [myDictKeys objectAtIndex:i], [myDictKeys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            [formData appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [formData appendData:parameterKey];
        }
        
        [formData appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    } 
    
    
    [formData appendData:[[NSString stringWithFormat:@"--%@--\r\n", aBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return formData;
}

#pragma mark - 
#pragma mark ASIHTTPRequestDelegate conformance

- (void)requestDone:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    
    NSLog(@"RAWRESPONSE: %@", response);
    
    SBJsonParser *json = [[[SBJsonParser alloc] init] autorelease];
    NSDictionary *dict = [json objectWithString:response];
    
   // NSLog(@"response: %@", [dict description]);
    
    NSError *newError = nil; 
    
    // attempt to parse out the meta data, bail if there is an error
    id<NSObject> parsedMetadata = [self parseMetadata:dict error:&newError];
    
    //NSLog(@"parsedMetadata: %@", [parsedMetadata description]);
    
    if(newError != nil) {
        [[request.userInfo objectForKey:@"callback"] filterAPIOperation:request didFailWithError:newError];
        return;
    }
    
    // attempt to parse out the actual data, bail if there is an error
    id<NSObject> parsedResponse = [self parseResults:dict withType:request.type error:&newError];
    
    if(newError != nil) {
        [[request.userInfo objectForKey:@"callback"] filterAPIOperation:request didFailWithError:newError];
        return;
    }
    
    [[request.userInfo objectForKey:@"callback"] filterAPIOperation:request didFinishWithData:parsedResponse withMetadata:parsedMetadata];
    
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    
    [[request.userInfo objectForKey:@"callback"] filterAPIOperation:request didFailWithError:error];
}

#pragma mark - Cleanup methods

- (void)removeNilEntries:(NSDictionary *)dict {
    
    NSArray *allKeys = [dict allKeys];
    for (NSString *key in allKeys) {
        id entry = [dict objectForKey:key];
        if (entry == [NSNull null]) {
            [dict setValue:[NSString string] forKey:key];
        }
        else if ([entry isKindOfClass:[NSDictionary class]]) {
            [self removeNilEntries:entry];
        }
        else if ([entry isKindOfClass:[NSArray class]]) {
            for (id arrayEntry in entry) {
                if ([arrayEntry isKindOfClass:[NSDictionary class]]) {
                    [self removeNilEntries:arrayEntry];
                }
            }
        }
    }
}

#pragma mark - 
#pragma mark Parse Result Methods

-(id)parseMetadata:(id)results error:(NSError**)err {
    
    id returnObject = nil;
    
   	if ([results objectForKey:@"error"] != [NSNull null]) {
		NSDictionary *errorResult = [results objectForKey:@"error"];
        *err = [NSError errorWithDomain:[errorResult objectForKey:@"domain"] 
								   code:0
							   userInfo:errorResult];
        return nil;
	}
	else {
		err = nil;
	}
        
    // right now all we have for metadata is the paginator, eventually we may need to make this a dictionary or something
        
    NSDictionary *pageDict = [results objectForKey:@"paginator"];
    if (pageDict != nil && (id)pageDict != [NSNull null]) {
        FilterPaginator *paginator = [[FilterPaginator alloc] initFromDictionary:pageDict];
        returnObject = paginator;
    }
    
    return [returnObject autorelease];
}

-(id)parseResults:(id)results withType:(FilterAPIType)type error:(NSError**)err {
	
	id returnObject = nil;
	 Class class;
    
	if ([results objectForKey:@"error"] != [NSNull null]) {
		NSDictionary *errorResult = [results objectForKey:@"error"];
        *err = [NSError errorWithDomain:[errorResult objectForKey:@"domain"] 
								   code:0
							   userInfo:errorResult];
        
        return nil;
	}
	else {
		err = nil;
	}
    
    NSDictionary *resultDict = nil;
    id resultData = [results objectForKey:@"result"];
    if ([resultData isKindOfClass:[NSDictionary class]]) {
        resultDict = resultData;
        [self removeNilEntries:resultDict];
    }
    
	switch (type) {
		case kFilterAPITypeAccountDetails: 
            returnObject = [[FilterFanAccount alloc] initFromDictionary:resultDict];
			break;
            
        case kFilterAPITypeGetAccount: 
            returnObject = [[FilterUserAccount alloc] initFromDictionary:resultDict];
            break;
            
        case kFilterAPITypeShowDetails: 
            returnObject = [[FilterShow alloc] initFromDictionary:resultDict];
            break;
            
        case kFilterAPITypeBandDetails:
            returnObject = [[FilterBand alloc] initFromDictionary:resultDict];
            break;
            
        case kFilterAPITypeVenueDetails:
            returnObject = [[FilterVenue alloc] initFromDictionary:resultDict];
            break;
		
        case kFilterAPITypeBandShows: 
		case kFilterAPITypeGeoGetEvents:
        case kFilterAPITypeSearchShows:
        case kFilterAPITypeVenueShows:
            class = [FilterShow class];
			break;
			
		case kFilterAPITypeBandTracks:
            class = [FilterTrack class];
			break;
            
		case kFilterAPITypeVenueSearch:
        case kFilterAPITypeGeoGetVenues:
            class = [FilterVenue class];
			break;
            
		case kFilterAPITypeGeoGetBands:
		case kFilterAPITypeBandSearch: 
		case kFilterAPITypeGeoGetFeaturedBands: 
            class = [FilterBand class];
			break;
            
        case kFilterAPITypeAccountGetGenres:
		case kFilterAPITypeGetGenres: 
            class = [FilterGenre class];
			break;
            
        case kFilterAPITypeAccountNews:
            class = [FilterNews class];
            break;
            
		case kFilterAPITypeAccountShows:
            class = [FilterAccountShow class];
            break;
            
		case kFilterAPITypeAccountBands:			
            class = [FilterAccountBand class];
            break;
            
        case kFilterAPITypeAccountCheckins:
            class = [FilterCheckin class];
            break;
        case kFilterAPITypeBandVideos:
            class = [FilterVideo class];
            break;
		default:
            // Either we dont care what the result is or something went wrong
			returnObject = [results objectForKey:@"result"];
            return returnObject;
            break;
	}
    
    if([[results objectForKey:@"result"] isKindOfClass:[NSArray class]]) {
        NSArray *resultsArray = [results objectForKey:@"result"];
        NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *aDict in resultsArray) {
            
            [self removeNilEntries:aDict];
            id object = [[class alloc] initFromDictionary:aDict];
            [objectsArray addObject:object];
            [object release];
        }
        
        returnObject = objectsArray; 
    }
    
    
	return [returnObject autorelease];
}

#pragma mark - 
#pragma mark Singleton Methods
static FilterAPIOperationQueue *singleton = nil;

+(id)sharedInstance {
	@synchronized(self) {
		if(singleton == nil) {
			singleton = [[FilterAPIOperationQueue alloc] init];
		}
		return singleton;
	}
}

-(id)init {
	
	if((self = [super init])) {
		
		[self setMaxConcurrentOperationCount:10];
		
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"FilterAPIURLs" ofType:@"plist"];
        
        NSString *serverPlistPath = [[NSBundle mainBundle] pathForResource:@"FilterAPIServers" ofType:@"plist"];
        
        filterAPIURLs = [[NSArray alloc] initWithContentsOfFile:plistPath];
        
        NSDictionary *serverDictionary = [NSDictionary dictionaryWithContentsOfFile:serverPlistPath];
      //  NSLog(@"serverDICTIONARY: %@",[serverDictionary description]);
        
        API_URL = [[serverDictionary objectForKey:@"apiurl"] retain];
        API_MEDIA_URL = [[serverDictionary objectForKey:@"mediaurl"] retain];
        
        // Turn on datacaching
        [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
	}
	return self;
}

-(void)dealloc {
    
    [filterAPIURLs release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Queue maintenance methods

- (BOOL)isAPITypeInQueue:(FilterAPIType)type {
    for (ASIHTTPRequest *request in [self operations]) {
        if (request.type) {
            return YES;
        }
    }
	return NO;
}

- (void)removeAllOperations {
    for (ASIHTTPRequest *request in [self operations]) {
        [request clearDelegatesAndCancel];
    }
}

- (void)removeOperationsForCallback:(FilterView *)callback {
    for (ASIHTTPRequest *request in [self operations]) {
        if ([request.userInfo objectForKey:@"callback"] == callback) {
            [request clearDelegatesAndCancel];
        }
    }
	
}

#pragma mark - 
#pragma mark API Method(s)

- (void)FilterAPIRequestWithParams:(NSDictionary *)params andType:(FilterAPIType)type andCallback:(id<FilterAPIOperationDelegate>)callback {

    NSMutableString *url = [[NSMutableString alloc] initWithFormat:@"%@%@", API_URL, [filterAPIURLs objectAtIndex:type]];
    NSString *requestType = @"GET";
    NSString *pagination = @"";
    
    if ([params objectForKey:@"limit"] && [params objectForKey:@"page"]) {
        pagination = [NSString stringWithFormat:@"limit=%@&page=%@", [params objectForKey:@"limit"], [params objectForKey:@"page"]];
    }
    
    switch (type) {
        // GEO APIs
        case kFilterAPITypeGeoGetEvents:
            [url appendFormat:@"?%@&longitude=%1.4f&latitude=%1.4f&radius=100",pagination,[[FilterLocationManager sharedInstance] lastLocation].coordinate.longitude,
                            [[FilterLocationManager sharedInstance] lastLocation].coordinate.latitude];
            break;
        case kFilterAPITypeGeoGetBands:
            [url appendFormat:@"?latitude=%1.4f&longitude=%1.4f&radius=100",[[params objectForKey:@"latitude"] floatValue],[[params objectForKey:@"longitude"] floatValue]];
            break;
        case kFilterAPITypeGeoGetVenues:
            [url appendFormat:@"?latitude=%1.4f&longitude=%1.4f&radius=100",[[params objectForKey:@"latitude"] floatValue],[[params objectForKey:@"longitude"] floatValue]];
            if (![pagination isEqualToString:@""]) {
                [url appendFormat:@"&%@", pagination];
            }
            break;
        // Band APIs
        case kFilterAPITypeBandFollow:
            [url appendFormat:@"%d/", [[params objectForKey:@"bandID"] intValue]];
            requestType = @"POST";
            params = [[NSDictionary alloc] init];
            break;
        case kFilterAPITypeBandUnfollow:
            [url appendFormat:@"%d/", [[params objectForKey:@"bandID"] intValue]];
            requestType = @"DELETE";
            break;
        case kFilterAPITypeBandDetails:
            [url appendFormat:@"%d/", [[params objectForKey:@"bandID"] intValue]];
            break;
        case kFilterAPITypeBandShows:
            [url appendFormat:@"%d/shows/", [[params objectForKey:@"bandID"] intValue]];
            if (![pagination isEqualToString:@""]) {
                [url appendFormat:@"?%@", pagination];
            }
            break;
        case kFilterAPITypeBandTracks:
            [url appendFormat:@"%d/tracks/", [[params objectForKey:@"bandID"] intValue]];
            if (![pagination isEqualToString:@""]) {
                [url appendFormat:@"?%@", pagination];
            }
            break;
        case kFilterAPITypeBandVideos:
            [url appendFormat:@"%d/videos/", [[params objectForKey:@"bandID"] intValue]];
            break;
        case kFilterAPITypeBandSearch:
            [url appendFormat:@"?query=%@&%@", [params objectForKey:@"searchString"], pagination];
            break;
        // Track APIs
        case kFilterAPITypeDownloadTrack:
            [url appendFormat:@"%d/", [[params objectForKey:@"trackID"] intValue]];
            break;
        // Show APIs
        case kFilterAPITypeShowBookmark:
            [url appendFormat:@"%d/", [[params objectForKey:@"showID"] intValue]];
            requestType = @"POST";
            break;
        case kFilterAPITypeShowUnbookmark:
            [url appendFormat:@"%d/", [[params objectForKey:@"showID"] intValue]];
            requestType = @"DELETE";
            params = [[NSDictionary alloc] init];
            break;
        case kFilterAPITypeSearchShows:
            [url appendFormat:@"?query=%@&%@&longitude=%1.4f&latitude=%1.4f&radius=100",[params objectForKey:@"search"],pagination, 
             [[FilterLocationManager sharedInstance] lastLocation].coordinate.longitude, 
             [[FilterLocationManager sharedInstance] lastLocation].coordinate.latitude];
            break;
        case kFilterAPITypeShowDetails:
            [url appendFormat:@"%@/", [params objectForKey:@"showID"]];
            break;
        // Venue APIs
        case kFilterAPITypeVenueDetails:
            [url appendFormat:@"%@/", [params objectForKey:@"ID"]];
            break;
        case kFilterAPITypeVenueSearch:
            [url appendFormat:@"?query=%@&%@", [params objectForKey:@"searchString"], pagination];
            break;
        case kFilterAPITypeVenueShows:
            [url appendFormat:@"%@/shows/future/?%@", [params objectForKey:@"ID"], pagination];
            break;
        // Account APIs
        case kFilterAPITypeAccountNews:
        case kFilterAPITypeAccountShows:
        case kFilterAPITypeAccountCheckins:
        case kFilterAPITypeAccountBands:
            if (![pagination isEqualToString:@""]) {
                [url appendFormat:@"?%@", pagination];
            }
            break;
        // Special case
        case kFilterAPITypeAccountProfilePicture: {
            NSData *data = [self dataForPOSTWithDictionary:params boundary:@"q1w2e3r4t5y6u7i8o91234"];
            ASIHTTPRequest *request = [self createBaseRequestWithURL:url andType:type withCallback:callback];
            [self postWithRequest:request andOptions:data];
            return;
        }
            break;
        // Plain POST Requests
        case kFilterAPITypeAccountModify:
        case kFilterAPITypeAccountCreate:
        case kFilterAPITypeAccountChangePassword:
        case kFilterAPITypeAccountAddGenres:
        case kFilterAPITypeLogin:
        case kFilterAPITypeCreateCheckin:
            requestType = @"POST";
            break;
        // Plain DELETE requests
        case kFilterAPITypeAccountDeleteProfilePicture:
            requestType = @"DELETE";
            break;
        // Plain GET requests
        case kFilterAPITypeAccountDetails:
        case kFilterAPITypeGetAccount:
        case kFilterAPITypeGeoGetFeaturedBands:
        case kFilterAPITypeGetGenres:
        case kFilterAPITypeAccountGetGenres:
            break;
        default:
            break;
    }
    
    ASIHTTPRequest *request = [self createBaseRequestWithURL:url andType:type withCallback:callback];
    
    if ([requestType isEqualToString:@"GET"]) {
        [self getWithRequest:request];
    }
    else if([requestType isEqualToString:@"POST"]) {
        [self postWithRequest:request andOptions:params];
    }
    else if([requestType isEqualToString:@"DELETE"]) {
        [self deleteWithRequest:request];
    }
}

@end
