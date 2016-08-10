//
//  PopoverButtonView.h
//
//  Created by Gabe Nadel on 6/11/14.
//

#pragma mark - Imports

#import <UIKit/UIKit.h>
#import "FPPopoverController.h"
#import "ResourceTimeSelectionViewController.h"
#import "ButtonViewDelegate.h"
#import "ResourceListViewController.h"

#pragma mark - Forward Declarations

@class PopoverButtonView;

#pragma mark - Public Interface

@interface PopoverButtonView : UIButton <FPPopoverControllerDelegate, ButtonViewDelegate>

#pragma mark - Properties

@property (nonatomic, copy)     NSArray						*items;
@property (nonatomic, copy)     NSArray						*values;
@property (nonatomic, copy)		NSString					*noItemsText;
@property (nonatomic, copy)		NSString					*selectItemText;
@property (nonatomic, copy)		NSString					*editItemText;
@property (nonatomic, assign)   BOOL                        editMode;
@property (nonatomic, copy)		NSString					*placeholderString;
@property (nonatomic, copy)		NSString                    *selectRowString;
@property (nonatomic, copy)		NSString					*vdsSetting;
@property (nonatomic, strong)   NSString                    *selectedValue;
@property (nonatomic)           entryType                   selectedEntryType;
@property (nonatomic, assign)	NSInteger					selectedItemIndex;
@property (nonatomic, copy)		RepositionBlock				repositionBlock;
@property (nonatomic, copy)		CloseBlock                  closeBlock;
@property (nonatomic, assign)   NSInteger                   totalValuesCount;
@property (nonatomic)           BOOL                        isSearchable;
@property (nonatomic, strong)	UIView*						containerView;
@property (nonatomic)           BOOL                        \thresholdExceeded;
@property (nonatomic, assign)   db_ResourceType             resourceType;
@property (nonatomic)           NSInteger                   tag;
@property (nonatomic, strong)   NSMutableArray              *fieldsDataArray;

@property (nonatomic, strong)   ResourceTimeSelectionViewController *selectionViewController;
@property (nonatomic, strong)   FPPopoverController                 *fpPopoverController;

@property (nonatomic, weak)     ResourceListViewController      *resourceListViewController;
@property (nonatomic, copy)		NSString                        *editDistributionDetailUID;
@property (nonatomic, copy)		NSDate                          *editDistributionCurrentDate;

#pragma mark - Public Methods

- (void)openPopover;
- (void)closePopover;

@end
