//
//  Styles.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/20/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#ifndef Styles_h
#define Styles_h

#define HEADER_TEXT_FONT @"Quicksand-Regular"
#define HEADER_TEXT_SIZE 20.f

#define TAB_BAR_SELECTED_FONT @"Quicksand-Bold"
#define TAB_BAR_CHANNEL_NAME_FONT @"Quicksand-Bold"
#define TAB_BAR_FOLLOWERS_FONT @"Quicksand-Regular"
#define TAB_BAR_FOLLOWER_NUMBER_FONT @"Quicksand-Bold"


#define CHANNEL_CREATION_USER_TEXT_ENTRY_PLACEHOLDER_FONT @"Quicksand-LightItalic"

#define CHANNEL_CREATION_USER_TEXT_ENTRY_FONT @"Quicksand-Bold"


#define CHANNEL_CREATION_BUTTON_FONT @"Quicksand-Regular"

#define TAB_BAR_FONT_SIZE 17.f
#define FOLLOWERS_TEXT_FONT_SIZE 15.f


#define CREATE_CHANNEL_BUTTON_FONT_SIZE 19.f


#define TAB_BAR_ALPHA 0.7

#define DEFAULT_FONT @"Quicksand-Regular"
#define BUTTON_FONT @"Quicksand-Regular"
#define PLACEHOLDER_FONT @"Quicksand-BoldItalic"
#define TITLE_TEXT_FONT @"Quicksand-Bold"

#define SWITCH_LABEL_FONT @"Futura-Medium"

#pragma mark Navigation Bars

#define NAVIGATION_BAR_TEXT_COLOR colorWithRed:(21.f/255.f) green:(71.f/255.f) blue:(97.f/255.f) alpha:1
#define NAVIGATION_BAR_BUTTON_FONT DEFAULT_FONT
#define NAVIGATION_BAR_BUTTON_FONT_SIZE 15.f

#define FILTER_LEVEL_BLUR 30
#define BUTTON_LABEL_SHADOW_BLUR_RADIUS 3.f
#define BUTTON_LABEL_SHADOW_YOFFSET 1.5f


#pragma mark - Sign In -
#define ERROR_ANIMATION_TEXT_COLOR whiteColor
#define ERROR_ANIMATION_FONT_SIZE 20


#pragma mark - Feed -

#pragma mark NOT IN USE
#define FEED_BACKGROUND_COLOR 0.918
#define STORY_BACKGROUND_COLOR colorWithRed: 0.8 green:0.8 blue:0.8 alpha:1
#define SWITCH_CATEGORY_BAR_FONT_SIZE 27.f
#define FEED_TITLE_TEXT_COLOR blackColor
#define FEED_TITLE_FONT @"HelveticaNeue-Italic"
#define FEED_TITLE_FONT_SIZE 20
#define USERNAME_FONT @"HelveticaNeue-Bold"
#define USERNAME_FONT_SIZE 18
#define DATE_AND_LIKES_FONT @"HelveticaNeue-Light"
#define DATE_AND_LIKES_FONT_SIZE 16.f

#pragma mark - ADK -

#define ADK_NAV_BAR_COLOR [UIColor colorWithWhite:1.0 alpha:1]
#define SETTINGS_NAV_BAR_COLOR [UIColor lightGrayColor]

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

#define DONE_BUTTON_COLOR clearColor
#define KEYBOARD_TOOLBAR_FONT_SIZE 22.f

#pragma mark Preview

#define PUBLISH_BUTTON_LABEL_FONT_SIZE PREVIEW_BUTTON_FONT_SIZE
#define PUBLISH_BUTTON_LABEL_COLOR_ACTIVE PREVIEW_PUBLISH_COLOR
#define PUBLISH_BUTTON_LABEL_COLOR_INACTIVE grayColor


#pragma mark - AVES -

#define AVE_BACKGROUND_COLOR blackColor

#pragma mark Text

#define TEXT_AVE_FONT DEFAULT_FONT
#define TEXT_AVE_FONT_SIZE 20
#define TEXT_AVE_COLOR blackColor

#define TEXT_OVER_AVE_BACKGROUND_ALPHA 0.7
#define TEXT_OVER_AVE_PULLBAR_COLOR clearColor

#pragma mark Images

#define CIRCLE_OVER_IMAGES_BORDER_WIDTH 3.f
#define CIRCLE_OVER_IMAGES_COLOR blackColor
#define CIRCLE_OVER_IMAGES_HIGHLIGHT_COLOR blueColor

#define CIRCLE_OVER_IMAGES_ALPHA 0.4
#define POINTS_ON_CIRCLE_ALPHA 0.5

#define TAB_DIVIDER_COLOR clearColor

#define TAB_BUTTON_BACKGROUND_IMAGE @"dark_fade_box"

#define CHANNEL_TAB_BAR_BACKGROUND_COLOR [UIColor colorWithWhite:0.f alpha:0.5]

#endif /* Styles_h */
