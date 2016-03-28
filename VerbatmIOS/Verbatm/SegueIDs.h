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
#define SIGN_IN_SEGUE @"segue_id_sign_in"
// unwind segues back to master
#define UNWIND_SEGUE_FROM_LOGIN_TO_MASTER @"unwind_to_master_vc_from_login"

#pragma mark - ADK -

#define ADK_SEGUE @"segue_id_adk"
#define UNWIND_SEGUE_FROM_ADK_TO_MASTER @"unwind_to_master_vc_from_adk"

#define BRING_UP_EDITCONTENT_SEGUE @"segue_id_edit_content_view"

#define SEGUE_TO_QUESTION_PAGE @"segue_id_question_page"
#define UNWIND_SEGUE_QUESTION_PAGE @"segue_id_unwind_from_question_page"

#define SETTINGS_PAGE_MODAL_SEGUE @"presentSettingsPage"

#define ARTICLE_DISPLAY_VC_ID @"article_display_vc"

#define TERMS_CONDITIONS_VC_SEGUE_ID @"Accept_Terms_And_Conditions_Segue"

#endif /* SegueIDs_h */
