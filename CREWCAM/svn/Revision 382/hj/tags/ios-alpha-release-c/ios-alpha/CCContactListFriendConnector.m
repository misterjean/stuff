//
//  CCContactListConnector.m
//  Crewcam
//
//  Created by Ryan Brink on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCContactListFriendConnector.h"

@implementation CCContactListFriendConnector

- (NSArray *) loadFriends
{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    NSMutableArray *namesOfContacts = [[NSMutableArray alloc] init];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef people  = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    // Iterate through all the people in the address book
    for(int contactIndex = 0;contactIndex < ABAddressBookGetPersonCount(addressBook); contactIndex++)
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(people, contactIndex);
        
        ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        NSString *phoneNumberString;
        
        // Iterate through all the numbers, looking for a mobile number
        for(CFIndex phoneNumberIndex = 0; phoneNumberIndex < ABMultiValueGetCount(phones); phoneNumberIndex++)
        {       
            NSString *mobileLabel = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(phones, phoneNumberIndex);
            if (![mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
                continue;
            
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, phoneNumberIndex);   
            phoneNumberString = (__bridge_transfer NSString *)phoneNumberRef;            
            
            NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"/:.+ -)("];
            phoneNumberString = [[phoneNumberString componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];            
        }
        
        // Did we find a mobile number?
        if (phoneNumberString == nil)
            continue;                            
        
        CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        NSString *firstNameString = (__bridge_transfer NSString *)firstName; 
        
        CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        NSString *lastNameString = (__bridge_transfer NSString *)lastName;         
        
        // Search for duplicates
        NSString *fullNameString = [[NSString alloc] initWithFormat:@"%@ %@", firstNameString, lastNameString];
        BOOL isDuplicate = NO;
        for (NSString *name in namesOfContacts)
        {
            if ([name isEqualToString:fullNameString])
            {
                isDuplicate = YES;
                break;
            }
        }
        
        if (isDuplicate)
            continue;
        
        [namesOfContacts addObject:fullNameString];
        
        if (firstName != nil && lastName != nil)
        {
            [contacts addObject:[[CCContactListPerson alloc] initWithFirstName:firstNameString andLastName:lastNameString andUniqueID:phoneNumberString]];
        }
    }
    
    CFRelease(addressBook);

    return contacts;
}

@end
