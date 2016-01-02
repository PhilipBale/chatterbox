//
//  PrimaryViewController.m
//  Chatterbox
//
//  Created by Philip Bale on 12/24/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "PrimaryViewController.h"
#import "PrimaryWindowController.h"

@interface PrimaryViewController () <PeoplePickerViewDelegate>

@property (nonatomic, weak) PrimaryWindowController *primaryWindowController;
@property (nonatomic, strong) NSAppleScript* scriptObject;
@property (nonatomic, strong) NSTimer* progressTimer;

@property (nonatomic) NSInteger messageCount;
@property (nonatomic) NSInteger quantity;

@end

@implementation PrimaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.peoplePickerView.target = self;
    self.peoplePickerView.delegate = self;
    
    [self.peoplePickerView addProperty:kABPhoneProperty];
    [self.peoplePickerView removeProperty:kABEmailProperty];
    [self.peoplePickerView removeProperty:kABEmailHomeLabel];
}

- (void)enableFields:(BOOL)value
{
    self.primaryWindowController = [[NSApp keyWindow] windowController];
    if (value) {
        [self.primaryWindowController.actionToolbarItem setLabel:@"Start"];
        [self.primaryWindowController.actionToolbarItem setImage:[NSImage imageNamed:@"start_icon"]];
        
    } else {
        
        [self.primaryWindowController.actionToolbarItem setLabel:@"Quit"];
        [self.primaryWindowController.actionToolbarItem setImage:[NSImage imageNamed:@"stop_icon"]];
    }
    [self.peoplePickerView setHidden:!value];
    [self.phoneNumberTextField setEnabled:value];
    [self.messageTextField setEnabled:value];
    [self.quantityTextField setEnabled:value];
    [self.delayTextField setEnabled:value];
    [self.antispamCheckbox setEnabled:value];
    [self.smsRadioButton setEnabled:value];
    [self.iMessageRadioButton setEnabled:value];
}

- (IBAction)actionButtonPressed:(id)sender
{
    NSLog(@"Action button pressed");
    if ([[sender label] containsString:@"Start"]) {
        [self startButtonPressed:sender];
    } else {
        [self stopButtonPressed:sender];
    }
}

- (IBAction)startButtonPressed:(id)sender
{
    NSLog(@"Start button pressed");
    
    if (![self validateFields]) return;
    
    [self enableFields:NO];
    
    
    
    //http://www.tenshu.net/2015/02/send-imessage-and-sms-with-applescript.html
    
    NSString *randPortion = @"\"\"";
    if (self.antispamCheckbox.state == NSOnState) {
        randPortion = @"rnd";
    }
    
    NSString *serviceType = @"service \"SMS\"";
    if (self.iMessageRadioButton.state == NSOnState) {
        serviceType =  @"(service 1 whose service type is iMessage)";
    }
    
    self.messageCount = 0;
    self.quantity = [[self.quantityTextField.stringValue stringByReplacingOccurrencesOfString:@"," withString:@""] intValue];
    [self.progressBar setMinValue:0.0];
    [self.progressBar setDoubleValue:0.0];
    [self.progressBar setMaxValue:self.quantity];
    
    NSString *payload = [NSString stringWithFormat:@"\
                         repeat %li times\n\
                         set rnd to (random number from 1 to 200)\n\
                         set rnd to rnd as string\n\
                         tell application \"Messages\" to send \"%@\" & %@ to buddy \"%@\" of %@ \n\
                         delay %@ \n\
                         end repeat", self.quantity, self.messageTextField.stringValue, randPortion, self.phoneNumberTextField.stringValue, serviceType, self.delayTextField.stringValue];
    
    NSLog(@"Payload: %@", payload);
    
    
    self.scriptObject = [[NSAppleScript alloc] initWithSource: payload];
    NSNumber *delay = [NSNumber numberWithInteger:[self.delayTextField.stringValue integerValue]];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:[delay floatValue]
                                                          target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDictionary* errorDict;
        NSAppleEventDescriptor* returnDescriptor = NULL;
        
        returnDescriptor = [self.scriptObject executeAndReturnError: &errorDict];
        
        if (returnDescriptor != NULL)
        {
            NSLog(@"Successful exection");
            // successful execution
            if (kAENullEvent != [returnDescriptor descriptorType])
            {
                // script returned an AppleScript result
                if (cAEList == [returnDescriptor descriptorType])
                {
                    // result is a list of other descriptors
                }
                else
                {
                    // coerce the result to the appropriate ObjC type
                }
            }
        }
        else
        {
            NSLog(@"Error: %@", errorDict);
            // no script result, handle error here
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self enableFields:YES];
        });
    });
    
}
- (IBAction)messageTypeSwitched:(id)sender {
    
}

- (void)updateProgressBar {
    
    self.messageCount++;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressBar incrementBy:1.0];
    });
    
    if (self.quantity == self.messageCount) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    
}

- (void)peoplePickerViewClicked
{
    NSArray *records = [self.peoplePickerView selectedRecords];
    BOOL recordValid = NO;
    NSString *phoneNumber = @"";
    
    for (ABPerson *record in records)
    {
        if ([record valueForProperty:kABPhoneProperty]) {
            
            recordValid = YES;
            
            ABMultiValue *phoneNumbers = [record valueForProperty:kABPhoneProperty];
            NSInteger count = [phoneNumbers count];
            
            if (count == 1) {
                phoneNumber = [phoneNumbers valueAtIndex:0];
            } else {
                for (int i = 0; i < count; i++) {
                    NSString *label = [phoneNumbers labelAtIndex:i];
                    
                    // Give priority to iPhone
                    if ([label containsString:kABPhoneiPhoneLabel] || [label containsString:kABPhoneMobileLabel]) {
                        phoneNumber = [phoneNumbers valueAtIndex:i];
                        break;
                    }
                    
                    phoneNumber = [phoneNumbers valueAtIndex:i];
                }
            }
            
            
        }
        
    }
    
    if (recordValid) {
        phoneNumber = [[[[[phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSLog(@"Assigning phone number: %@", phoneNumber);
        if ([phoneNumber length] == 10) {
            phoneNumber = [NSString stringWithFormat:@"+1%@", phoneNumber];
        } else if ([phoneNumber length] == 11) {
            phoneNumber = [NSString stringWithFormat:@"+%@", phoneNumber];
        }
        
        [self.phoneNumberTextField setStringValue:phoneNumber];
    }
    
    NSLog(@"Delegate clicked");
}

- (IBAction)stopButtonPressed:(id)sender
{
    [NSApp terminate: nil];
    [self enableFields:YES];
    NSLog(@"Stop button pressed");
}

- (BOOL)validateFields {
    BOOL valid = YES;
    NSString *errorMessage;
    
    if ([self.phoneNumberTextField.stringValue length] != 12) {
        valid = NO;
        errorMessage = @"Phone number must be in format: +1(area)(number). Ex: +13021234567";
    } else if ([self.messageTextField.stringValue length] == 0) {
        valid = NO;
        errorMessage = @"Please enter a message to send";
    } else if ([self.quantityTextField.stringValue length] == 0) {
        valid = NO;
        errorMessage = @"Please enter a quantity to send";
    } else if ([self.delayTextField.stringValue length] == 0) {
        valid = NO;
        errorMessage = @"Please enter a delay length";
    }
    
    if (!valid) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Input Error"];
        [alert setInformativeText:errorMessage];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
    
    return valid;
}

@end
