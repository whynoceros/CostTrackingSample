//
//  ServiceWorkOrders.m
//
//  Created by Gabe Nadel on 3/19/14.
//
//

#import "ServiceWorkOrder.h"


@implementation ServiceWorkOrder

@dynamic unitID;
@dynamic parentUnitID;
@dynamic unitLevel;
@dynamic unitCode;
@dynamic unitDesc;
@dynamic parentPath;
@dynamic udf1;
@dynamic udf2;
@dynamic udf3;
@dynamic udf4;
@dynamic udf5;
@dynamic activeYN;
@dynamic createDate;
@dynamic userID;
@dynamic environmentUID;

//Fetches for common ServiceWorkOrder tasks, purpose described in names and predicates

+ (NSFetchRequest *)getServiceWorkOrdersForEnvironment: (NSString *)resourceUID {
	NSFetchRequest *fetch	= [NSFetchRequest fetchRequestWithEntityName: @"ServiceWorkOrder"];
	fetch.predicate			= [NSPredicate predicateWithFormat: @"environmentUID =[c] %@", resourceUID];
	fetch.sortDescriptors	= @[ [NSSortDescriptor sortDescriptorWithKey: @"unitDesc" ascending: YES] ];
	
	return fetch;
}

+ (NSFetchRequest *)getServiceWorkOrderForUnitID: (int32_t)unitID {
	NSFetchRequest *fetch	= [NSFetchRequest fetchRequestWithEntityName: @"ServiceWorkOrder"];
	fetch.predicate			= [NSPredicate predicateWithFormat: @"unitID = %i", unitID];
	
	return fetch;
}


+ (NSFetchRequest *)getServiceWorkOrdersForUnitCodeandParentPath: (NSString *)resourceUID withParentPath:(NSString*)parentPath withUnitCode:(NSString*)unitCode{
    NSFetchRequest *fetch	= [NSFetchRequest fetchRequestWithEntityName: @"ServiceWorkOrder"];
    fetch.predicate			= [NSPredicate predicateWithFormat: @"environmentUID =[c] %@ AND parentPath =[c] %@ AND unitCode =[c] %@", resourceUID, parentPath, unitCode];
    fetch.sortDescriptors	= @[ [NSSortDescriptor sortDescriptorWithKey: @"unitDesc" ascending: YES] ];
    
    return fetch;
}

//Update existing serviceWorkOrders for a single Environment, from external system, to CoreData
+ (void)updateServiceWorkOrdersFromNetwork: (NSArray *)serviceWorkOrders forEnvironment: (NSString *)environmentUID {
	NSManagedObjectContext *backgroundContext		= [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
	backgroundContext.persistentStoreCoordinator	= self.fieldTimeAppDelegate.persistentStoreCoordinator;
	backgroundContext.undoManager					= nil;
	
	__block NSException *exception = nil;
	[backgroundContext performBlockAndWait: ^{
		@try {
			//Delete the existing service work orders from the environment
			NSFetchRequest *existingServiceWorkOrdersFetch	= [ServiceWorkOrder getServiceWorkOrdersForEnvironment: environmentUID];
			NSArray *existingServiceWorkOrders		= [backgroundContext executeFetchRequest: existingServiceWorkOrdersFetch error: nil];
			
			for(ServiceWorkOrder *serviceWorkOrder in existingServiceWorkOrders)
				if ([existingServiceWorkOrders count]>0) {
                    [backgroundContext deleteObject: serviceWorkOrder];
                }
            
			
			//Insert the new service work order, mapping external fields to CoreData attributes
			for(apx_ServiceWorkOrder *apxServiceWorkOrder in serviceWorkOrders) {
				ServiceWorkOrder *newServiceWorkOrder		= [NSEntityDescription insertNewObjectForEntityForName: @"ServiceWorkOrder" inManagedObjectContext: backgroundContext];
				newServiceWorkOrder.environmentUID             = environmentUID;
				newServiceWorkOrder.unitID                     = apxServiceWorkOrder.unitID;
				newServiceWorkOrder.parentUnitID               = apxServiceWorkOrder.parentUnitID;
                newServiceWorkOrder.unitLevel                  = apxServiceWorkOrder.unitLevel;
				newServiceWorkOrder.unitCode                   = apxServiceWorkOrder.unitCode;
                newServiceWorkOrder.unitDesc                   = apxServiceWorkOrder.unitDesc;
                newServiceWorkOrder.parentPath                 = apxServiceWorkOrder.parentPath;
				newServiceWorkOrder.udf1                       = apxServiceWorkOrder.udf1;
                newServiceWorkOrder.udf2                       = apxServiceWorkOrder.udf2;
                newServiceWorkOrder.udf3                       = apxServiceWorkOrder.udf3;
                newServiceWorkOrder.udf4                       = apxServiceWorkOrder.udf4;
                newServiceWorkOrder.udf5                       = apxServiceWorkOrder.udf5;
                newServiceWorkOrder.activeYN                   = apxServiceWorkOrder.activeYN;
				newServiceWorkOrder.userID                     = apxServiceWorkOrder.userID;
                newServiceWorkOrder.createDate                 = [NSDate date];
                
			}
            
			//Save the context
			[backgroundContext saveContext];
		} @catch (NSException *ex) {
			exception = [ex copy];
		}
	}];
	
	if (exception)
		@throw exception;
}


@end
