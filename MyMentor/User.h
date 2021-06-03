//
//  User.h
//  MyMentorV2
//
//  Created by Walter Yaron on 7/26/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * admin;
@property (nonatomic, retain) NSString * contentWorldId;
@property (nonatomic, retain) NSString * deviceIdentifier;
@property (nonatomic, retain) NSString * firstName_en_us;
@property (nonatomic, retain) NSString * firstName_he_il;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * parentGroupId;
@property (nonatomic, retain) NSDate * updateAt;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * contentTester;
@property (nonatomic, retain) NSNumber * changeEnvironment;

@end
