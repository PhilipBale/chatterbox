//
//  PrimaryViewController.h
//  Chatterbox
//
//  Created by Philip Bale on 12/24/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PeoplePickerView.h"
#import <AddressBook/ABPeoplePickerView.h>
#import <AddressBook/AddressBook.h>

@interface PrimaryViewController : NSViewController
 
@property (weak) IBOutlet PeoplePickerView *peoplePickerView;

@property (weak) IBOutlet NSTextField *phoneNumberTextField;
@property (weak) IBOutlet NSTextField *messageTextField;
@property (weak) IBOutlet NSTextField *quantityTextField;
@property (weak) IBOutlet NSTextField *delayTextField;
@property (weak) IBOutlet NSButton *antispamCheckbox;
@property (weak) IBOutlet NSButton *smsRadioButton;
@property (weak) IBOutlet NSButton *iMessageRadioButton;
@property (weak) IBOutlet NSProgressIndicator *progressBar;

@end
