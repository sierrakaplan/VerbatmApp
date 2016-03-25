//
//  Styles.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/20/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#ifndef Styles_h
#define Styles_h


#define VERBATM_GOLD_COLOR [UIColor yellowColor]

#define DEFAULT_FONT @"Quicksand-Regular"
#define BUTTON_FONT @"Quicksand-Regular"
#define PLACEHOLDER_FONT @"Quicksand-BoldItalic"
#define TITLE_TEXT_FONT @"Quicksand-Bold"

#define HEADER_TEXT_FONT @"Quicksand-Regular"
#define HEADER_TEXT_SIZE 20.f

#pragma mark - Sign In -

#define ERROR_ANIMATION_TEXT_COLOR whiteColor
#define ERROR_ANIMATION_FONT_SIZE 20

#pragma mark - Bottom Tab Bar -

#define TAB_BAR_ALPHA 0.7

#pragma mark - Profile -

#define USER_CHANNEL_LIST_FONT @"Quicksand-Regular"
#define USER_CHANNEL_LIST_FONT_SIZE 20.f

//Font of the headers of the user_channel list
#define INFO_LIST_HEADER_FONT @"Quicksand-Bold"  
#define INFO_LIST_HEADER_FONT_SIZE 20.f

#pragma mark Channel Tab Bar

#define CHANNEL_TAB_BAR_DIVIDER_COLOR clearColor
#define CHANNEL_TAB_BAR_BACKGROUND_COLOR_UNSELECTED [UIColor colorWithWhite:0.f alpha:0.5]
#define CHANNEL_TAB_BAR_BACKGROUND_COLOR_SELECTED [UIColor colorWithWhite:1.f alpha:0.8]

#define CHANNEL_TAB_BAR_NAME_FONT @"Quicksand-Bold"
#define CHANNEL_TAB_BAR_NAME_FONT_SIZE 17.f
#define CHANNEL_TAB_BAR_NAME_FONT_ATTRIBUTE [UIFont fontWithName:CHANNEL_TAB_BAR_NAME_FONT size:CHANNEL_TAB_BAR_NAME_FONT_SIZE]

#define CHANNEL_TAB_BAR_FOLLOWERS_FONT @"Quicksand-Regular"
#define CHANNEL_TAB_BAR_FOLLOWERS_FONT_SIZE 15.f
#define CHANNEL_TAB_BAR_FOLLOWERS_FONT_ATTRIBUTE [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:CHANNEL_TAB_BAR_FOLLOWERS_FONT_SIZE]

#define CHANNEL_TAB_BAR_FOLLOWING_INFO_FONT @"Quicksand-Bold"
#define CHANNEL_TAB_BAR_FOLLOWING_INFO_FONT_SIZE 17.f
#define CHANNEL_TAB_BAR_FOLLOWING_INFO_FONT_ATTRIBUTE [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWING_INFO_FONT size:CHANNEL_TAB_BAR_FOLLOWING_INFO_FONT_SIZE]

#define CHANNEL_CREATION_USER_TEXT_ENTRY_PLACEHOLDER_FONT @"Quicksand-LightItalic"
#define CHANNEL_CREATION_USER_TEXT_ENTRY_FONT @"Quicksand-Bold"
#define CHANNEL_CREATION_BUTTON_FONT @"Quicksand-Regular"

#define CREATE_CHANNEL_BUTTON_FONT_SIZE 19.f


#pragma mark - Feed - 

#define REPOST_BUTTON_TEXT_FONT_SIZE 15.f
#define REPOST_VIEW_BACKGROUND_COLOR [UIColor colorWithWhite:0.f alpha:0.8]

#define CHANNEL_USER_LIST_CHANNEL_NAME_FONT_SIZE 20.f
#define CHANNEL_USER_LIST_USER_NAME_FONT_SIZE 15.f

#define LIKE_SHARE_BAR_BACKGROUND_COLOR [UIColor clearColor]//[UIColor colorWithWhite:0.f alpha:0.3]

#pragma mark - Page Views -

#define PAGE_BACKGROUND_COLOR blackColor

#pragma mark Text

#define TEXT_PAGE_VIEW_FONT DEFAULT_FONT
#define TEXT_PAGE_VIEW_FONT_SIZE 50
#define TEXT_PAGE_VIEW_COLOR blackColor

#define TEXT_PAGE_VIEW_BACKGROUND_ALPHA 0.7
#define TEXT_PAGE_VIEW_PULLBAR_COLOR clearColor

#pragma mark Images

#define CIRCLE_OVER_IMAGES_BORDER_WIDTH 3.f
#define CIRCLE_OVER_IMAGES_COLOR blackColor
#define CIRCLE_OVER_IMAGES_HIGHLIGHT_COLOR blueColor

#define CIRCLE_OVER_IMAGES_ALPHA 0.4
#define POINTS_ON_CIRCLE_ALPHA 0.5


#pragma mark - Navigation Bars -

#define NAVIGATION_BAR_TEXT_COLOR whiteColor
#define NAVIGATION_BAR_BUTTON_FONT DEFAULT_FONT
#define NAVIGATION_BAR_BUTTON_FONT_SIZE 15.f

#define FILTER_LEVEL_BLUR 30
#define BUTTON_LABEL_SHADOW_BLUR_RADIUS 3.f
#define BUTTON_LABEL_SHADOW_YOFFSET 1.5f


#pragma mark - ADK -

#define ADK_NAV_BAR_COLOR CHANNEL_TAB_BAR_BACKGROUND_COLOR_UNSELECTED 
#define SETTINGS_NAV_BAR_COLOR [UIColor blackColor]

#define TITLE_TEXT_COLOR blackColor
#define TITLE_TEXT_SIZE 20.f

#pragma mark PinchViews

#define DELETED_ITEM_BACKGROUND_COLOR clearColor
#define DELETING_ITEM_COLOR redColor
#define SELECTED_ITEM_COLOR NAVIGATION_BAR_TEXT_COLOR

#define PLAY_VIDEO_ICON_OPACITY 1.0
#define PINCHVIEW_FONT_SIZE 14
#define PINCHVIEW_FONT_SIZE_BIG 20
#define PINCHVIEW_FONT_SIZE_REALLY_BIG 30
#define PINCHVIEW_FONT_SIZE_REALLY_REALLY_BIG 40
#define PINCHVIEW_BACKGROUND_COLOR clearColor
#define PINCHVIEW_BORDER_COLOR whiteColor
#define PINCHVIEW_BORDER_WIDTH 1.f
#define COLLECTION_PINCHVIEW_BORDER_WIDTH 5.f
#define COLLECTION_PINCHVIEW_SHADOW_RADIUS 5.f

#pragma mark Content Editing View

#define TEXT_SCROLLVIEW_BACKGROUND_COLOR whiteColor

#pragma mark Verbatm Keyboard Toolbar

#define KEYBOARD_TOOLBAR_FONT_SIZE 22.f

#pragma mark Preview

#define PUBLISH_BUTTON_LABEL_FONT_SIZE PREVIEW_BUTTON_FONT_SIZE
#define PUBLISH_BUTTON_LABEL_COLOR_ACTIVE PREVIEW_PUBLISH_COLOR
#define PUBLISH_BUTTON_LABEL_COLOR_INACTIVE grayColor


#pragma mark - Discover/Search -

#define CHANNEL_LIST_CELL_SEPERATOR_COLOR [UIColor grayColor]


#endif /* Styles_h */
