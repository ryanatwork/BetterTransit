//
//  HBFeedLoader.h
//  HoosBus
//
//  Created by Yaogang Lian on 10/1/09.
//  Copyright 2009 Yaogang Lian. All rights reserved.
//

#import "BTFeedLoader.h"
#import "BTPredictionEntry.h"

@interface HBFeedLoader : BTFeedLoader <NSXMLParserDelegate>
{
	BTPredictionEntry *entry; // info for one route
	NSMutableString *contentOfCurrentElement;
	NSUInteger tdCount;
}

@property (nonatomic, retain) BTPredictionEntry *entry;
@property (nonatomic, retain) NSMutableString *contentOfCurrentElement;

- (void)parseXMLData:(NSData *)xmlData parseError:(NSError **)error;

// XML parser delegate methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

@end