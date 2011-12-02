//
//  AppDelegate.m
//  XMLTest
//
//  Created by Takayama Fumihiko on 11/11/16.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation NSString (HashBraces)

- (NSString*) stringByReplacingHashBracesOccurrencesOfDictionary:(NSDictionary*)replacementDictionary options:(NSStringCompareOptions)options
{
  NSString* string = [NSString stringWithString:self];

  NSRange searchRange = NSMakeRange(0, [string length]);

  // withDictionary is {"#{XXX}" => "111", "#{YYY}" => "222"}.
  // Then replace "#{XXX}" to "111", "#{YYY}" to "222".

  for (;;) {
    // ------------------------------------------------------------
    // Searching "#{"
    NSRange replacementBegin = [string rangeOfString:@"#{" options:options range:searchRange];
    if (replacementBegin.location == NSNotFound) break;

    // Setting length to 0 here becuase we adjust it after replacing.
    searchRange.location = replacementBegin.location + 1;
    searchRange.length = 0;

    // ------------------------------------------------------------
    // Replacing "#{...}"
    NSRange range = NSMakeRange(replacementBegin.location,
                                [string length] - replacementBegin.location);
    for (NSString* target in replacementDictionary) {
      NSRange replacementRange = [string rangeOfString:target
                                               options:(options | NSAnchoredSearch)
                                                 range:range];
      if (replacementRange.location != NSNotFound) {
        string = [string stringByReplacingCharactersInRange:replacementRange
                                                 withString:[replacementDictionary objectForKey:target]];
        searchRange.location = replacementBegin.location;
        break;
      }
    }

    searchRange.length = [string length] - searchRange.location;
  }

  return string;
}

@end

@implementation AppDelegate

@synthesize window = _window;

- (void) applicationDidFinishLaunching:(NSNotification*)aNotification
{
  NSError* error = nil;
  NSString* xmlstring = [NSString stringWithContentsOfFile:@"/Library/org.pqrs/KeyRemap4MacBook/prefpane/checkbox.xml"
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];

  xmlstring = @"#{aaa}#{xxx}#{yyy}#{zzz} #{UNKNOWN} #{aaa} #{xxx} #{yyy} #{zzz}#{TARGET1}#{UNKNOWN}";

  NSMutableDictionary* replacement = [NSMutableDictionary new];
  for (int i = 0; i < 100; ++i) {
    [replacement setObject:[NSString stringWithFormat:@"VALUE%d", i]
                    forKey:[NSString stringWithFormat:@"#{TARGET%d}", i]];
  }
  [replacement setObject:@"AAAAAAAA" forKey:@"#{aaa}"];
  //                       #{xxx}
  [replacement setObject:@"XXXXXX" forKey:@"#{xxx}"];
  [replacement setObject:@"Y" forKey:@"#{yyy}"];
  [replacement setObject:@"" forKey:@"#{zzz}"];

  xmlstring = [xmlstring stringByReplacingHashBracesOccurrencesOfDictionary:replacement options:NSLiteralSearch];

  NSLog(@">%@<", xmlstring);
}

@end
