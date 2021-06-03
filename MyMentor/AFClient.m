//
//  User.m
//  BjoyPlus
//
//  Created by yaron walter on 3/13/12.
//  Copyright (c) 2012 Walter Apps. All rights reserved.
//

#import "AFClient.h"

@implementation AFClient
@synthesize client;

static AFClient *myInstance = nil;

#define     parse          @"http://files.parse.com/"

- (id)init
{
    if (self = [super init]) 
    {
        client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:parse]];
    }
    return self;
}


+(AFClient*) sharedInstance
{
    @synchronized (self)
    {
        if (myInstance == nil)
        {
           myInstance = [[self alloc] init];
        }
    }
    
    return myInstance;
}

@end
