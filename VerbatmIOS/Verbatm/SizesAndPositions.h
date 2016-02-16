//
//  Sizes.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/20/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#ifndef SizesAndPositions_h
#define SizesAndPositions_h

#pragma mark -POV View -
#define CREATOR_CHANNEL_BAR_HEIGHT 50.f


#define TITLE_BAR_HEIGHT 60.f

#pragma mark - Custom Navigation Bar -
#define CUSTOM_NAV_BAR_HEIGHT 40.f

#pragma mark - Exit CV constants-

#define EXIT_CV_BUTTON_WIDTH 42
#define EXIT_CV_BUTTON_HEIGHT 30
#define EXIT_CV_BUTTON_WALL_OFFSET 10

#define BAR_TOP_OFFSET 10.f


#define NAV_BAR_HEIGHT 50.f
#define NAV_ICON_OFFSET 7.f
#define NAV_ICON_SIZE (NAV_BAR_HEIGHT - NAV_ICON_OFFSET*2)


#pragma mark -Delete position-
#define DELETE_ICON_X_OFFSET 20
#define DELETE_ICON_Y_OFFSET 50
#define DELETE_ICON_WIDTH 20
#define DELETE_ICON_HEIGHT 26

#pragma mark - Sign In -

#define SIGN_IN_ERROR_VIEW_HEIGHT 100.f
#define SIGNIN_ERROR_LABEL_PADDING 30.f


#pragma mark - Feed -

#define CATEGORY_SWITCH_OFFSET 5.f

#pragma mark Story table view cell

#define STORY_CELL_PADDING 10
#define STORY_CELL_HEIGHT 160
//verticle distance between text on the feed
#define FEED_TEXT_GAP 15
//sets the distance between a label and the left of the screen
#define FEED_TEXT_X_OFFSET 10

#define TITLE_LABEL_HEIGHT 35
#define USERNAME_LABEL_HEIGHT 25
#define DATE_AND_LIKES_LABEL_HEIGHT 18

#pragma mark Topics table view cell

#define TOPIC_CELL_PADDING 10
#define TOPIC_CELL_HEIGHT 80

#pragma mark Compose Story Button

#define COMPOSE_STORY_BUTTON_SIZE 90.f
#define COMPOSE_STORY_BUTTON_OFFSET 20.f
#define COMPOSE_STORY_OUTER_CIRCLE_SIZE 110.f


#pragma mark - Media Dev VC -

#define SWITCH_ORIENTATION_ICON_SIZE 70.f
#define FLASH_ICON_SIZE_HEIGHT 70.f
#define FLASH_ICON_SIZE_WIDTH 25.f
#define CAPTURE_MEDIA_BUTTON_SIZE 100.f
#define CLOSE_CAMERA_BUTTON_SIZE 40.f

#define PROGRESS_CIRCLE_SIZE 100.f
#define PROGRESS_CIRCLE_THICKNESS 10.0f
#define PROGRESS_CIRCLE_OPACITY 0.6f

#define CAPTURE_MEDIA_BUTTON_OFFSET 10.f

#define TRANSLATION_CONTENT_DEV_CONTAINER_VIEW_THRESHOLD 50.f


#pragma mark - Content Dev VC -

#pragma mark - Gallery

#define GALLERY_COLUMNS_PORTRAIT 3
#define GALLERY_COLUMNS_LANDSCAPE 5

#pragma mark - Editing Content View

#define TEXT_VIEW_BOTTOM_PADDING 15.f

#pragma mark Toolbar

#define TEXT_TOOLBAR_HEIGHT 30.f
#define TEXT_TOOLBAR_BUTTON_OFFSET 9.f
#define TEXT_TOOLBAR_BUTTON_WIDTH 70.f

#pragma mark - Preview

#define PUBLISH_BUTTON_OFFSET 20.f

#define PUBLISH_BUTTON_SIZE 75.f

#define BACK_BUTTON_OFFSET 10.f

#pragma mark - Content Dev Pull Bar

#pragma mark Verbatm Image Scroll View
#define VIEW_Y_OFFSET 50
#define VIEW_WALL_OFFSET 20

#define TEXTFIELD_BORDER_WIDTH 0.8f
#define AUTO_SCROLL_OFFSET 10
#define CONTENT_SIZE_OFFSET 20
#define OFFSET_BELOW_ARTICLE_TITLE 30
//distance between elements on the content view page
#define ELEMENT_Y_OFFSET_DISTANCE 25
#define ELEMENT_X_OFFSET_DISTANCE 50
//the distance we want the cursor from the base of the view at all times. When the
//cursor is below this threshold we scroll the view down
#define CURSOR_BASE_GAP 10

#define CENTERING_OFFSET_FOR_TEXT_VIEW 30
//if the image is up- you can scroll up and have it turn to circles. This gives that scrollup distance
#define SCROLLDISTANCE_FOR_PINCHVIEW_RETURN 200

#pragma mark PinchViews

#define PINCHVIEW_DIVISION_FACTOR_FOR_TWO 2
#define MIN_PINCHVIEW_SIZE 100
//distance two fingers must travel for the horizontal pinch to be accepted
#define HORIZONTAL_PINCH_THRESHOLD 100
#define PINCH_VIEW_DELETING_THRESHOLD 80
#define PINCH_DISTANCE_THRESHOLD_FOR_NEW_MEDIA_TILE_CREATION (MEDIA_TILE_SELECTOR_HEIGHT * 3.f/4.f)

#pragma mark Media Select Tile

#define MEDIA_TILE_SELECTOR_HEIGHT 80.f
#define ADD_MEDIA_BUTTON_OFFSET 10

#pragma mark - AVES -

#define LIKE_BUTTON_SIZE_WIDTH 25.f
#define LIKE_BUTTON_SIZE_HEIGHT 25.f

#define LIKE_BUTTON_OFFSET 20.f

#pragma mark Text

#define TEXT_OVER_AVE_TOP_OFFSET 80.f
#define TEXT_OVER_AVE_STARTING_HEIGHT 100.f
#define TEXT_OVER_AVE_PULLBAR_HEIGHT 40.f
#define TEXT_OVER_AVE_ANIMATION_THRESHOLD 30.f
#define TEXT_OVER_AVE_BORDER 30.f

#pragma mark Images

#define CIRCLE_RADIUS 50.f
#define CIRCLE_OFFSET 15.f

#define POINTS_ON_CIRCLE_RADIUS 10.f
#define TAP_THRESHOLD 20.f//the threshold to select a circle - but also to start panning
#define	SLIDE_THRESHOLD 70.f

#define TEXT_VIEW_OVER_MEDIA_Y_OFFSET 150.f
#define TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT 70.f


#define PAN_CIRCLE_CENTER_Y (self.frame.size.height - CIRCLE_RADIUS - CIRCLE_OFFSET)


#define TAB_BUTTON_PADDING 25.f
#define TAB_DIVIDER_WIDTH 2.f

#define TAB_BAR_HEIGHT 40.f


#define PROFILE_HEADER_HEIGHT 35.f
#define USER_CELL_VIEW_HEIGHT 80.f

#define PROFILE_NAV_BAR_HEIGHT (PROFILE_HEADER_HEIGHT + USER_CELL_VIEW_HEIGHT)
#define LIKE_SHARE_BAR_HEIGHT 40.f



#define CHANNEL_CREATION_VIEW_WALLOFFSET_X 30.f
#define CHANNEL_CREATION_VIEW_Y_OFFSET (PROFILE_NAV_BAR_HEIGHT + 90.f)

//for PROFILE NAV BAR ARROW
#define ARROW_EXTENSION_BAR_HEIGHT 0.f// 15.f TEMP
#define ARROW_FRAME_HEIGHT ARROW_EXTENSION_BAR_HEIGHT
#define ARROW_FRAME_WIDTH 30.f
#define ARROW_IMAGE_WALL_OFFSET 2.f


#define NO_POVS_LABEL_WIDTH 300.f

#endif
