//
//  PeoplePickerView.h
//  Chatterbox
//
//  Created by Philip Bale on 12/25/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <AddressBook/AddressBook.h>

@protocol PeoplePickerViewDelegate;

@interface PeoplePickerView : ABPeoplePickerView


@property (nonatomic, weak) id<PeoplePickerViewDelegate> delegate;

@end


@protocol PeoplePickerViewDelegate <NSObject>

-(void)peoplePickerViewClicked;

@end