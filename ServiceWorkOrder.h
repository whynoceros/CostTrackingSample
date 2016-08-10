//
//  ServiceWorkOrder.h
//  
//  Created by Gabe Nadel on 3/19/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ServiceWorkOrder : NSManagedObject

@property (nonatomic)           int32_t unitID;
@property (nonatomic)           int32_t parentUnitID;
@property (nonatomic)           int32_t unitLevel;
@property (nonatomic, retain)   NSString * unitCode;
@property (nonatomic, retain)   NSString * unitDesc;
@property (nonatomic, retain)   NSString * parentPath;
@property (nonatomic, retain)   NSString * udf1;
@property (nonatomic, retain)   NSString * udf2;
@property (nonatomic, retain)   NSString * udf3;
@property (nonatomic, retain)   NSString * udf4;
@property (nonatomic, retain)   NSString * udf5;
@property (nonatomic)           BOOL activeYN;
@property (nonatomic, retain)   NSDate * createDate;
@property (nonatomic)           int32_t userID;
@property (nonatomic, retain)   NSString * environmentUID;


+ (NSFetchRequest *)getServiceWorkOrdersForEnvironment: (NSString *)resourceUID;
+ (NSFetchRequest *)getServiceWorkOrderForUnitID: (int32_t)unitID;
+ (NSFetchRequest *)getServiceWorkOrdersForUnitCodeandParentPath: (NSString *)resourceUID withParentPath:(NSString*)parentPath withUnitCode:(NSString*)unitCode;
+ (void)updateServiceWorkOrdersFromNetwork: (NSArray *)serviceWorkOrders forEnvironment: (NSString *)environmentUID;

@end
