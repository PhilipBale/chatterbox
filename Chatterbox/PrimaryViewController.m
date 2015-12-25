//
//  PrimaryViewController.m
//  Chatterbox
//
//  Created by Philip Bale on 12/24/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "PrimaryViewController.h"

@interface PrimaryViewController () <PeoplePickerViewDelegate>

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
    [self.peoplePickerView setHidden:!value];
    [self.phoneNumberTextField setEnabled:value];
    [self.messageTextField setEnabled:value];
    [self.quantityTextField setEnabled:value];
    [self.delayTextField setEnabled:value];
    [self.antispamCheckbox setEnabled:value];
    [self.smsRadioButton setEnabled:value];
    [self.iMessageRadioButton setEnabled:value];
}

- (IBAction)startButtonPressed:(id)sender
{
    NSLog(@"Start button pressed");
    [self enableFields:NO];
    
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    
    //http://www.tenshu.net/2015/02/send-imessage-and-sms-with-applescript.html
    
    NSString *randPortion = @"\"\"";
    if (self.antispamCheckbox.state == NSOnState) {
        randPortion = @"rnd";
    }
    
    NSString *serviceType = @"service \"SMS\"";
    if (self.iMessageRadioButton.state == NSOnState) {
        serviceType =  @"(service 1 whose service type is iMessage)";
    }
    
    NSString *payload = [NSString stringWithFormat:@"\
    repeat %@ times\n\
    set rnd to (random number from 1 to 200)\n\
    set rnd to rnd as string\n\
    tell application \"Messages\" to send \"%@\" & %@ to buddy \"%@\" of %@ \n\
    delay %@ \n\
    end repeat", self.quantityTextField.stringValue, self.messageTextField.stringValue, randPortion, self.phoneNumberTextField.stringValue, serviceType, self.delayTextField.stringValue];
    
    NSLog(@"Payload: %@", payload);

    
    NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource: payload];
    
    returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
    
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
    
    [self enableFields:YES];
}
- (IBAction)messageTypeSwitched:(id)sender {
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
    [self enableFields:YES];
    NSLog(@"Stop button pressed");
}

@end
