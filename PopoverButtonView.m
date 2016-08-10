//
//  PopoverButtonView.m
//
//  Created by Gabe Nadel on 6/11/14.
//

#pragma mark - Imports

#import "PopoverButtonView.h"

#pragma mark - Private Interface

@interface PopoverButtonView()
@property (assign) BOOL popoverVisible;
@property (assign) BOOL valueChanged;
@property (nonatomic, strong) FPPopoverController *popoverController;

- (void)internalInit;
- (void)closePopoverInternal;
- (void)openPopoverInternal;
- (ResourceTimeSelectedBlock)selectedBlockForPopover: (ResourceTimeSelectionViewController *)viewController;
- (void)showNoItemsAlert;
@end

#pragma mark - Implementation

@implementation PopoverButtonView
@synthesize items                   = _items;
@synthesize values                  = _values;
@synthesize noItemsText             = _noItemsText;
@synthesize selectItemText          = _selectItemText;
@synthesize selectedValue           = _selectedValue;
@synthesize selectedItemIndex       = _selectedItemIndex;
@synthesize selectRowString         = _selectRowString;
@synthesize closeBlock              = _closeBlock;
@synthesize popoverVisible          = _popoverVisible;
@synthesize valueChanged            = _valueChanged;
@synthesize totalValuesCount        = _totalValuesCount;
@synthesize vdsSetting              = _vdsSetting;
@synthesize popoverController       = _popoverController;
@synthesize isSearchable            = _isSearchable;
@synthesize selectionViewController = _selectionViewController;
@synthesize fpPopoverController     = _fpPopoverController;
@synthesize placeholderString       = _placeholderString;
@synthesize containerView           = _containerView;
@synthesize thresholdExceeded       = _thresholdExceeded;
@synthesize resourceListViewController = _resourceListViewController;
@synthesize resourceType            = _resourceType;
@synthesize editItemText            = _editItemText;
@synthesize fieldsDataArray         = _fieldsDataArray;
@synthesize editMode                = _editMode;
@synthesize selectedEntryType       = _selectedEntryType;
#pragma mark - Initialization

CONFIGURE_INTERNAL_INIT(internalInit);

- (void)internalInit {
	//Set default the selected index
	self.selectedItemIndex = -1;
	
	//Set default for the "no items" text (fetch returned no results)
	self.noItemsText = NSLocalizedString(@"No Items", nil);
	
	//Configure the images for the button states
	[self setBackgroundImage: [[UIImage imageNamed: @"buttonModalCancel"] stretchableImageWithLeftCapWidth: 10.0 topCapHeight: 10.0] forState: UIControlStateNormal];
	[self setBackgroundImage: [[UIImage imageNamed: @"buttonModalCancelPressed"] stretchableImageWithLeftCapWidth: 10.0 topCapHeight: 10.0] forState: UIControlStateHighlighted];
	
	//Configure the content alignment and font
	self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	self.contentEdgeInsets			= UIEdgeInsetsMake(0, 8, 0, 40);
	self.titleLabel.font			= [UIFont boldSystemFontOfSize: 15.0];
	[self setTitleColor: [UIColor colorWithRed: 64 / 255.0 green: 64 / 255.0 blue: 64 / 255.0 alpha: 1.0] forState: UIControlStateNormal];
	[self setTitleColor: [UIColor whiteColor] forState: UIControlStateHighlighted];

	//Handle the tap for this button
	[self removeTarget: nil action: nil forControlEvents: UIControlEventAllEvents];
	[self addTarget: self action: @selector(openPopoverInternal) forControlEvents: UIControlEventTouchUpInside];
    
    self.containerView = nil;
}

#pragma mark - Property Implementation

//Set selectedItemText (Visible to Users) and selectedItemIndex after tapping, or on load/refresh

- (void)setSelectItemText:(NSString *)selectItemText {
	_selectItemText = [selectItemText copy];
	//Set selected item for new or unsaved record
    if (self.selectedItemIndex == -1){
		[self setTitle: self.selectItemText forState: UIControlStateNormal];
    }
    //Set selected item for existing record being edited
    if (self.editItemText.length > -1) {
        [self setTitle: self.editItemText forState: UIControlStateNormal];
    }
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex {
	_selectedItemIndex = selectedItemIndex;
    

	dispatch_async(dispatch_get_main_queue(), ^{
        //If top row (close button) is tapped or no index is selected, reset to previously selected item
		if (self.selectedItemIndex == -1 || self.selectedItemIndex == NSNotFound)
			[self setTitle: self.selectItemText forState: UIControlStateNormal];
        
        //Handle selection cases for filtered results, using filtered items array, indexes
        else if (self.selectionViewController.isFiltered == YES) {
            [self setTitle: [self.selectionViewController.filteredItems objectAtIndex: self.selectedItemIndex] forState: UIControlStateNormal];
            self.editItemText = [self.selectionViewController.filteredItems objectAtIndex: self.selectedItemIndex];
            
            
            NSString *selectedValue = [NSString stringWithFormat:@"%@",[self.selectionViewController.filteredValues objectAtIndex:self.selectedItemIndex]];
            if(selectedValue){
                NSInteger newSelectedItemIndex = [self.selectionViewController.values indexOfObject:selectedValue];
                
                if (self.selectionViewController.isFiltered) {
                    newSelectedItemIndex = [self.selectionViewController.filteredValues indexOfObject:selectedValue];
                }
                
                _selectedItemIndex = (int)newSelectedItemIndex;
            }
         }
        //Handle selection for non-filtered cases
        else if(self.items && (self.items.count > self.selectedItemIndex)){
            [self setTitle: [self.items objectAtIndex: self.selectedItemIndex] forState: UIControlStateNormal];
        }
        //Handle case of existing item being edited
        if (self.editItemText.length > 0 && (int)self.selectedItemIndex < 0) {
            [self setTitle: self.editItemText forState: UIControlStateNormal];
        }
    
    });
    
}

#pragma mark - Popover

- (void)openPopoverInternal {
	//Keep the button highlighted during open
	dispatch_async(dispatch_get_main_queue(), ^{
		self.highlighted = YES;
	});
    
    //If user search results prefrence is reached ("threshold"), open popover to refine search
        if (self.thresholdExceeded) {
        
                [self openPopover];
                return;
            }
	//If threshold is not reached, open as is
	if (self.items && self.items.count > 1) {
        if (self.repositionBlock) {
            self.repositionBlock(^{ [self openPopover]; });
        }
        else
            [self openPopover];
    }
	else {
        //If popover is not populated, show user alert
		if (!self.items)
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.highlighted = NO;
		});
		
		[self showNoItemsAlert];
        
	}
}

- (void)openPopover {
    //Open popover with full (unfiltered results)
    self.selectionViewController.isFiltered = NO;
    if (self.popoverVisible)
        return;
    
    self.valueChanged	= NO;
    self.popoverVisible = YES;
    
    self.selectionViewController = [[ResourceTimeSelectionViewController alloc] init];
    self.selectionViewController.editDistributionDetailUID = self.editDistributionDetailUID;
    self.selectionViewController.editDistributionCurrentDate = self.editDistributionCurrentDate;

    self.selectionViewController.selectRowString = self.selectRowString;
    
    if (self.isSearchable) {
        self.selectionViewController.isSearchable = YES;
    }
    
    //Prompt user to refine search to yield results under threshold
    if (self.thresholdExceeded == YES) {
        self.placeholderString = NSLocalizedString(@"Begin searching to see results", nil) ;
        self.selectionViewController.totalValuesCount   = self.totalValuesCount;
        self.selectionViewController.tag                = self.tag;
    }
    else{
        self.selectionViewController.items  = self.items;
        self.selectionViewController.values = self.values;
    }
    
    //Pass relevant values/settings to selectionViewController from button
    NSString *thresholdString      = [[NSUserDefaults standardUserDefaults] objectForKey: @"SearchThreshold"];
    self.selectionViewController.resourceListViewController = self.resourceListViewController;
    self.selectionViewController.searchThreshold            = [thresholdString integerValue];
    self.selectionViewController.placeHolderString          = self.placeholderString;
    self.selectionViewController.selectedValue              = self.selectedValue;
    self.selectionViewController.selectedItemText           = self.selectItemText;
    self.selectionViewController.resourceType               = self.resourceType;
    self.selectionViewController.fieldsDataArray            = self.fieldsDataArray;
    self.selectionViewController.editMode                   = self.editMode;
    self.selectionViewController.selectedEntryType          = self.selectedEntryType;
    self.selectionViewController.resourceTimeSelectedBlock  = [self selectedBlockForPopover: self.selectionViewController];
    
    self.fpPopoverController    = [[FPPopoverController alloc] initWithViewController: self.selectionViewController delegate: self];
    self.popoverController      = self.fpPopoverController;
    
    if (self.popoverController.contentSize.height < self.selectionViewController.preferredContentSize.height)
        self.selectionViewController.preferredContentSize = self.popoverController.contentSize;
    
    [self.popoverController presentPopoverFromView: self];
    
    
}

- (void)closePopoverInternal {
	if (self.popoverController)
		[self.popoverController dismissPopoverAnimated: YES];
}

- (void)closePopover {
    
	if (!self.popoverVisible)
		return;
    
	//Close popover with animation, reset value that may have changed (filtering, selected item, etc...)
	self.popoverVisible = NO;
    self.selectionViewController.isFiltered = NO;
    
	[UIView animateWithDuration: 0.3 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut animations: ^{
		self.highlighted = NO;
	} completion: ^(BOOL finished) {
		if (self.closeBlock)
            
			self.closeBlock(self.valueChanged, self.tag, self.selectedItemIndex, self.selectedValue);
	}];

        if (self.selectionViewController.filteredValues) {
                self.selectionViewController.filteredValues = nil;
                self.selectionViewController.filteredItems  = nil;
            }
        if (self.totalValuesCount > self.selectionViewController.searchThreshold) {
                self.thresholdExceeded = YES;
            }
    //remove cached searchbar items
    [self.selectionViewController.stashedResults removeAllObjects];
}

- (void)showNoItemsAlert {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil message: self.noItemsText delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
	[alert show];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.highlighted = NO;
    });
}

- (UIView *)container {
    return self.containerView;
}

- (UIView *)view {
    return self;
}

#pragma mark - ResourceTimeSelectedBlock Typedef

- (ResourceTimeSelectedBlock)selectedBlockForPopover: (ResourceTimeSelectionViewController *)viewController {
	__weak PopoverButtonView *selfRef = self;
	//Pass vlock of info key info (selectedItemIndex, selectedItemIndex) to Parent object (ResourceTimeVC)
	ResourceTimeSelectedBlock selectedBlock = ^(NSUInteger selectedItemIndex, NSString *selectedItemIndex) {
        self.selectedValue = selectedValue;
		if (selfRef.selectedItemIndex != selectedItemIndex)
			selfRef.valueChanged = YES;
		
		selfRef.selectedItemIndex = selectedItemIndex;
		
		[selfRef closePopoverInternal];
	};
	
	return [selectedBlock copy];
}

#pragma mark - FPPopoverControllerDelegate Methods

- (void)popoverControllerDidDismissFPPopover:(FPPopoverController *)popoverController {
	[self closePopover];
}

#pragma mark - Memory Management

- (void)dealloc {
	NNILogDealloc();
	
}

@end
