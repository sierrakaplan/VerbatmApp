//
//  Styles.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/20/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#ifndef Styles_h
#define Styles_h


#define DEFAULT_FONT @"HelveticaNeue-Light"
#define BUTTON_FONT @"HelveticaNeue"
#define PLACEHOLDER_FONT @"HelveticaNeue-UltraLightItalic"

#define NAV_BAR_COLOR whiteColor
#define PREVIEW_PUBLISH_COLOR colorWithRed:(33.f/255.f) green:(169.f/255.f) blue:(255.f/255.f) alpha:1

#define FILTER_LEVEL_BLUR 30
#define BUTTON_LABEL_SHADOW_BLUR_RADIUS 3.f
#define BUTTON_LABEL_SHADOW_YOFFSET 1.5f




#pragma mark - Sign In -

#define ERROR_ANIMATION_TEXT_COLOR whiteColor
#define ERROR_ANIMATION_FONT_SIZE 30


#pragma mark - Feed -

#define FEED_BACKGROUND_COLOR 0.918
#define STORY_BACKGROUND_COLOR 0.827
#define SWITCH_CATEGORY_BAR_FONT_SIZE 30

#define USERNAME_FONT_SIZE 18
#define TITLE_FONT_SIZE 20
#define USERNAME_TEXT_COLOR blackColor
#define TITLE_TEXT_COLOR blackColor
#define USERNAME_FONT @"HelveticaNeue-Bold"
#define TITLE_FONT @"HelveticaNeue-Italic"

#pragma mark - ADK -

#define TELL_YOUR_STORY_COLOR whiteColor

#define WHAT_IS_IT_LIKE_COLOR blackColor
#define WHAT_IS_IT_LIKE_LABEL_TEXT_SIZE 23.f
#define WHAT_IS_IT_LIKE_FIELD_TEXT_SIZE 23.f

#define ADD_COVER_PIC_TEXT_SIZE 15.f
#define ADD_COVER_PIC_FONT @"HelveticaNeue-Light"
#define COVER_PIC_CIRCLE_COLORE whiteColor
#pragma mark PullBar

#define PREVIEW_BUTTON_FONT @"HelveticaNeue-Bold"
#define PREVIEW_BUTTON_FONT_SIZE 15

#pragma mark PinchViews

#define DELETED_ITEM_BACKGROUND_COLOR clearColor
#define DELETING_ITEM_COLOR redColor
#define SELECTED_ITEM_COLOR blueColor

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

#define TEXT_SCROLLVIEW_BACKGROUND_COLOR blackColor

#pragma mark Verbatm Keyboard Toolbar

#define DONE_BUTTON_COLOR clearColor
#define KEYBOARD_TOOLBAR_FONT_SIZE 22.f

#pragma mark Preview

#define PUBLISH_BUTTON_LABEL_FONT_SIZE PREVIEW_BUTTON_FONT_SIZE
#define PUBLISH_BUTTON_LABEL_COLOR PREVIEW_PUBLISH_COLOR


#pragma mark - AVES -

#define AVE_BACKGROUND_COLOR blackColor

#pragma mark Text

#define TEXT_AVE_FONT_SIZE 20
#define TEXT_AVE_COLOR whiteColor

#define TEXT_OVER_AVE_BACKGROUND_ALPHA 0.7
#define TEXT_OVER_AVE_PULLBAR_COLOR clearColor

#pragma mark Images

#define CIRCLE_OVER_IMAGES_BORDER_WIDTH 3.f
#define CIRCLE_OVER_IMAGES_COLOR whiteColor
#define CIRCLE_OVER_IMAGES_HIGHLIGHT_COLOR blueColor

#define CIRCLE_OVER_IMAGES_ALPHA 0.4
#define POINTS_ON_CIRCLE_ALPHA 0.5




#endif /* Styles_h */
