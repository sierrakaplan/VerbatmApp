//
//  SegueIDs.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/24/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#ifndef SegueIDs_h
#define SegueIDs_h

#pragma mark - Login -

// From Master VC
#define SEGUE_LOGIN_OR_SIGNUP @"login_or_signup_segue"

// Login (vs create account from first page)
#define SEGUE_LOGIN @"login_segue"

// Create account
#define SEGUE_WELCOME @"welcome_to_verbatm_segue"
#define SEGUE_TERMS_AND_CONDITIONS @"terms_and_conditions_segue"
#define SEGUE_CREATE_ACCOUNT @"create_account_segue"
#define SEGUE_FOLLOW_FRIENDS_FROM_FACEBOOK_LOGIN @"follow_friends_from_facebook"
#define SEGUE_ENTER_PHONE_CONFIRMATION_CODE @"enter_phone_code_segue" //from either login or create account nav
#define SEGUE_FOLLOW_FRIENDS @"follow_friends_segue"
#define SEGUE_CREATE_NAME @"create_name_segue"
#define SEGUE_CREATE_FIRST_POST_FROM_ONBOARDING @"first_post_segue"

#define SEGUE_CREATE_FIRST_POST_FROM_MASTER @"OnboardSegueFromMasterView"
// segue from master vc to onboarding
#define SEGUE_ONBOARDING_ALREADY_LOGGED_IN @"logged_in_onboarding_segue"

#define SEGUE_ONBOARD_FROM_ENTER_CODE @"OnboardFromEnterCodeSegue"

// unwind segues back to master from login/onboarding
#define UNWIND_SEGUE_PHONE_LOGIN_TO_MASTER @"phone_login_to_master_segue"
#define UNWIND_SEGUE_FACEBOOK_LOGIN_TO_MASTER @"facebook_login_to_master_segue"
#define UNWIND_SEGUE_FROM_ONBOARDING_TO_MASTER @"unwind_to_master_from_onboarding"

// ADK
#define ADK_SEGUE @"segue_id_adk"
#define UNWIND_SEGUE_FROM_ADK_TO_MASTER @"unwind_to_master_vc_from_adk"

#define SEGUE_TERMS_AND_CONDITIONS_FROM_SETTINGS @"terms_and_conditions_from_settings"

#endif /* SegueIDs_h */
