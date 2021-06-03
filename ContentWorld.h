//
//  ContentWorld.h
//  MyMentorV2
//
//  Created by Walter Yaron on 5/2/14.
//  Copyright (c) 2014 walterapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ContentWorld : NSManagedObject

@property (nonatomic, retain) NSString * category1_en_us;
@property (nonatomic, retain) NSString * category1_he_il;
@property (nonatomic, retain) NSString * category2_en_us;
@property (nonatomic, retain) NSString * category2_he_il;
@property (nonatomic, retain) NSString * category3_en_us;
@property (nonatomic, retain) NSString * category3_he_il;
@property (nonatomic, retain) NSString * category4_en_us;
@property (nonatomic, retain) NSString * category4_he_il;
@property (nonatomic, retain) NSString * name_en_us;
@property (nonatomic, retain) NSString * name_he_il;
@property (nonatomic, retain) NSString * worldId;

@end
