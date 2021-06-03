//
//  User.h
//  BjoyPlus
//
//  Created by yaron walter on 3/13/12.
//  Copyright (c) 2012 Walter Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface AFClient : NSObject

@property (nonatomic,strong) AFHTTPClient *client;

+(AFClient*)    sharedInstance;

@end
