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

// from master vc
#define CREATE_ACCOUNT_SEGUE @"segue_id_create_account"
#define SIGN_IN_SEGUE @"segue_id_sign_in"
// back and forth between the two
#define BACK_TO_CREATE_ACCOUNT_FROM_SIGN_IN @"segue_id_create_account_from_sign_in"
#define BACK_TO_SIGN_IN_FROM_CREATE_ACCOUNT @"segue_id_sign_in_from_create_account"
// unwind segues back to master
#define UNWIND_SEGUE_FROM_CREATE_ACCOUNT_TO_MASTER @"unwind_to_master_vc_from_create_account"
#define UNWIND_SEGUE_FROM_LOGIN_TO_MASTER @"unwind_to_master_vc_from_login"

#pragma mark - ADK -

#define ADK_SEGUE @"segue_id_adk"
#define UNWIND_SEGUE_FROM_ADK_TO_MASTER @"unwind_to_master_vc_from_adk"

#define BRING_UP_EDITCONTENT_SEGUE @"segue_id_edit_content_view"
#define UNWIND_SEGUE_EDIT_CONTENT_VIEW @"segue_id_unwind_from_edit_content_view"

#define SEGUE_TO_QUESTION_PAGE @"segue_id_question_page"
#define UNWIND_SEGUE_QUESTION_PAGE @"segue_id_unwind_from_question_page"


#endif /* SegueIDs_h */
