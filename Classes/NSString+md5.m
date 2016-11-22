//
//  NSString+md5.m
//  Boutiques
//
//  Created by Eric Chapman on 10/22/2010.
//  Copyright 2010 Google Inc.  All rights reserved.
//

#import "NSString+md5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (md5)

- (NSString *)md5 {
  
  const char *cStr = [self UTF8String];
  
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  
  CC_MD5( cStr, strlen(cStr), result );
  
  NSMutableString * returnString = [NSMutableString stringWithCapacity:2*CC_MD5_DIGEST_LENGTH];
  for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
    [returnString appendFormat:@"%02X",result[i]];
  }
  
  return returnString;
  
}

@end
