/*
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

extern const NSString* kFB_SDK_VersionNumber;

///////////////////////////////////////////////////////////////////////////////////////////////////

#ifdef DEBUG
#define FBLOG( s, ... ) do{}while(0)
#define FBLOG2( s, ... ) do{}while(0)
#else
#define FBLOG( s, ... ) do{}while(0)
#define FBLOG2( s, ... ) do{}while(0)
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef unsigned long long FBUID;
typedef unsigned long long FBID;

#define FBAPI_ERROR_DOMAIN @"api.facebook.com"

///////////////////////////////////////////////////////////////////////////////////////////////////
// Error codes

#define FBAPI_EC_SUCCESS 0
#define FBAPI_EC_UNKNOWN 1
#define FBAPI_EC_SERVICE 2
#define FBAPI_EC_METHOD 3
#define FBAPI_EC_TOO_MANY_CALLS 4
#define FBAPI_EC_BAD_IP 5
#define FBAPI_EC_HOST_API 6
#define FBAPI_EC_HOST_UP 7
#define FBAPI_EC_SECURE 8
#define FBAPI_EC_RATE 9
#define FBAPI_EC_PERMISSION_DENIED 10
#define FBAPI_EC_DEPRECATED 11
#define FBAPI_EC_VERSION 12

#define FBAPI_EC_PARAM 100
#define FBAPI_EC_PARAM_FBAPI_KEY 101
#define FBAPI_EC_PARAM_SESSION_KEY 102
#define FBAPI_EC_PARAM_CALL_ID 103
#define FBAPI_EC_PARAM_SIGNATURE 104
#define FBAPI_EC_PARAM_TOO_MANY 105
#define FBAPI_EC_PARAM_USER_ID 110
#define FBAPI_EC_PARAM_USER_FIELD 111
#define FBAPI_EC_PARAM_SOCIAL_FIELD 112
#define FBAPI_EC_PARAM_EMAIL 113
#define FBAPI_EC_PARAM_ALBUM_ID 120
#define FBAPI_EC_PARAM_PHOTO_ID 121
#define FBAPI_EC_PARAM_FEED_PRIORITY 130
#define FBAPI_EC_PARAM_CATEGORY 140
#define FBAPI_EC_PARAM_SUBCATEGORY 141
#define FBAPI_EC_PARAM_TITLE 142
#define FBAPI_EC_PARAM_DESCRIPTION 143
#define FBAPI_EC_PARAM_BAD_JSON 144
#define FBAPI_EC_PARAM_BAD_EID 150
#define FBAPI_EC_PARAM_UNKNOWN_CITY 151
#define FBAPI_EC_PARAM_BAD_PAGE_TYPE 152

#define FBAPI_EC_PERMISSION 200
#define FBAPI_EC_PERMISSION_USER 210
#define FBAPI_EC_PERMISSION_ALBUM 220
#define FBAPI_EC_PERMISSION_PHOTO 221
#define FBAPI_EC_PERMISSION_MESSAGE 230
#define FBAPI_EC_PERMISSION_MARKUP_OTHER_USER 240
#define FBAPI_EC_PERMISSION_STATUS_UPDATE 250
#define FBAPI_EC_PERMISSION_PHOTO_UPLOAD 260
#define FBAPI_EC_PERMISSION_SMS 270
#define FBAPI_EC_PERMISSION_CREATE_LISTING 280
#define FBAPI_EC_PERMISSION_EVENT 290
#define FBAPI_EC_PERMISSION_LARGE_FBML_TEMPLATE 291
#define FBAPI_EC_PERMISSION_LIVEMESSAGE 292
#define FBAPI_EC_PERMISSION_RSVP_EVENT 299

#define FBAPI_EC_EDIT 300
#define FBAPI_EC_EDIT_USER_DATA 310
#define FBAPI_EC_EDIT_PHOTO 320
#define FBAPI_EC_EDIT_ALBUM_SIZE 321
#define FBAPI_EC_EDIT_PHOTO_TAG_SUBJECT 322
#define FBAPI_EC_EDIT_PHOTO_TAG_PHOTO 323
#define FBAPI_EC_EDIT_PHOTO_FILE 324
#define FBAPI_EC_EDIT_PHOTO_PENDING_LIMIT 325
#define FBAPI_EC_EDIT_PHOTO_TAG_LIMIT 326
#define FBAPI_EC_EDIT_ALBUM_REORDER_PHOTO_NOT_IN_ALBUM 327
#define FBAPI_EC_EDIT_ALBUM_REORDER_TOO_FEW_PHOTOS 328
#define FBAPI_EC_MALFORMED_MARKUP 329
#define FBAPI_EC_EDIT_MARKUP 330
#define FBAPI_EC_EDIT_FEED_TOO_MANY_USER_CALLS 340
#define FBAPI_EC_EDIT_FEED_TOO_MANY_USER_ACTION_CALLS 341
#define FBAPI_EC_EDIT_FEED_TITLE_LINK 342
#define FBAPI_EC_EDIT_FEED_TITLE_LENGTH 343
#define FBAPI_EC_EDIT_FEED_TITLE_NAME 344
#define FBAPI_EC_EDIT_FEED_TITLE_BLANK 345
#define FBAPI_EC_EDIT_FEED_BODY_LENGTH 346
#define FBAPI_EC_EDIT_FEED_PHOTO_SRC 347
#define FBAPI_EC_EDIT_FEED_PHOTO_LINK 348
#define FBAPI_EC_EDIT_VIDEO_SIZE 350
#define FBAPI_EC_EDIT_VIDEO_INVALID_FILE 351
#define FBAPI_EC_EDIT_VIDEO_INVALID_TYPE 352
#define FBAPI_EC_EDIT_FEED_TITLE_ARRAY 360
#define FBAPI_EC_EDIT_FEED_TITLE_PARAMS 361
#define FBAPI_EC_EDIT_FEED_BODY_ARRAY 362
#define FBAPI_EC_EDIT_FEED_BODY_PARAMS 363
#define FBAPI_EC_EDIT_FEED_PHOTO 364
#define FBAPI_EC_EDIT_FEED_TEMPLATE 365
#define FBAPI_EC_EDIT_FEED_TARGET 366
#define FBAPI_EC_USERS_CREATE_INVALID_EMAIL 370
#define FBAPI_EC_USERS_CREATE_EXISTING_EMAIL 371
#define FBAPI_EC_USERS_CREATE_BIRTHDAY 372
#define FBAPI_EC_USERS_CREATE_PASSWORD 373
#define FBAPI_EC_USERS_REGISTER_INVALID_CREDENTIAL 374
#define FBAPI_EC_USERS_REGISTER_CONF_FAILURE 375
#define FBAPI_EC_USERS_REGISTER_EXISTING 376
#define FBAPI_EC_USERS_REGISTER_DEFAULT_ERROR 377
#define FBAPI_EC_USERS_REGISTER_PASSWORD_BLANK 378
#define FBAPI_EC_USERS_REGISTER_PASSWORD_INVALID_CHARS 379
#define FBAPI_EC_USERS_REGISTER_PASSWORD_SHORT 380
#define FBAPI_EC_USERS_REGISTER_PASSWORD_WEAK 381
#define FBAPI_EC_USERS_REGISTER_USERNAME_ERROR 382
#define FBAPI_EC_USERS_REGISTER_MISSING_INPUT 383
#define FBAPI_EC_USERS_REGISTER_INCOMPLETE_BDAY 384
#define FBAPI_EC_USERS_REGISTER_INVALID_EMAIL 385
#define FBAPI_EC_USERS_REGISTER_EMAIL_DISABLED 386
#define FBAPI_EC_USERS_REGISTER_ADD_USER_FAILED 387
#define FBAPI_EC_USERS_REGISTER_NO_GENDER 388

#define FBAPI_EC_AUTH_EMAIL 400
#define FBAPI_EC_AUTH_LOGIN 401
#define FBAPI_EC_AUTH_SIG 402
#define FBAPI_EC_AUTH_TIME 403

#define FBAPI_EC_SESSION_METHOD 451
#define FBAPI_EC_SESSION_REQUIRED 453
#define FBAPI_EC_SESSION_REQUIRED_FOR_SECRET 454
#define FBAPI_EC_SESSION_CANNOT_USE_SESSION_SECRET 455

#define FBAPI_EC_MESG_BANNED 500
#define FBAPI_EC_MESG_NO_BODY 501
#define FBAPI_EC_MESG_TOO_LONG 502
#define FBAPI_EC_MESG_RATE 503
#define FBAPI_EC_MESG_INVALID_THREAD 504
#define FBAPI_EC_MESG_INVALID_RECIP 505
#define FBAPI_EC_POKE_INVALID_RECIP 510
#define FBAPI_EC_POKE_OUTSTANDING 511
#define FBAPI_EC_POKE_RATE 512

#define FQL_EC_UNKNOWN_ERROR 600
#define FQL_EC_PARSER_ERROR 601
#define FQL_EC_UNKNOWN_FIELD 602
#define FQL_EC_UNKNOWN_TABLE 603
#define FQL_EC_NO_INDEX 604
#define FQL_EC_UNKNOWN_FUNCTION 605
#define FQL_EC_INVALID_PARAM 606
#define FQL_EC_INVALID_FIELD 607
#define FQL_EC_INVALID_SESSION 608

#define FBAPI_EC_REF_SET_FAILED 700
#define FBAPI_EC_FB_APP_UNKNOWN_ERROR 750
#define FBAPI_EC_FB_APP_FETCH_FAILED 751
#define FBAPI_EC_FB_APP_NO_DATA 752
#define FBAPI_EC_FB_APP_NO_PERMISSIONS 753
#define FBAPI_EC_FB_APP_TAG_MISSING 754

#define FBAPI_EC_DATA_UNKNOWN_ERROR 800
#define FBAPI_EC_DATA_INVALID_OPERATION 801
#define FBAPI_EC_DATA_QUOTA_EXCEEDED 802
#define FBAPI_EC_DATA_OBJECT_NOT_FOUND 803
#define FBAPI_EC_DATA_OBJECT_ALREADY_EXISTS 804
#define FBAPI_EC_DATA_DATABASE_ERROR 805
#define FBAPI_EC_DATA_CREATE_TEMPLATE_ERROR 806
#define FBAPI_EC_DATA_TEMPLATE_EXISTS_ERROR 807
#define FBAPI_EC_DATA_TEMPLATE_HANDLE_TOO_LONG 808
#define FBAPI_EC_DATA_TEMPLATE_HANDLE_ALREADY_IN_USE 809
#define FBAPI_EC_DATA_TOO_MANY_TEMPLATE_BUNDLES 810
#define FBAPI_EC_DATA_MALFORMED_ACTION_LINK 811
#define FBAPI_EC_DATA_TEMPLATE_USES_RESERVED_TOKEN 812

#define FBAPI_EC_NO_SUCH_APP 900
#define FBAPI_BATCH_TOO_MANY_ITEMS 950
#define FBAPI_EC_BATCH_ALREADY_STARTED 951
#define FBAPI_EC_BATCH_NOT_STARTED 952
#define FBAPI_EC_BATCH_METHOD_NOT_ALLOWED_IN_BATCH_MODE 953

#define FBAPI_EC_EVENT_INVALID_TIME 1000
#define FBAPI_EC_INFO_NO_INFORMATION 1050
#define FBAPI_EC_INFO_SET_FAILED 1051

#define FBAPI_EC_LIVEMESSAGE_SEND_FAILED 1100
#define FBAPI_EC_LIVEMESSAGE_EVENT_NAME_TOO_LONG 1101
#define FBAPI_EC_LIVEMESSAGE_MESSAGE_TOO_LONG 1102

#define FBAPI_EC_PAGES_CREATE 1201

///////////////////////////////////////////////////////////////////////////////////////////////////

NSMutableArray* FBCreateNonRetainingArray(void);

BOOL FBIsDeviceIPad(void);
