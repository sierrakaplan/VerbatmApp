//
//  Sizes.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/20/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#ifndef SizesAndPositions_h
#define SizesAndPositions_h


#pragma mark - Media Dev VC -

#define SWITCH_ICON_SIZE 50.f
#define FLASH_ICON_SIZE 50.f
#define CAMERA_BUTTON_SIZE 100.f
#define PROGRESS_CIRCLE_SIZE 100.f
#define PROGRESS_CIRCLE_THICKNESS 10.0f
#define PROGRESS_CIRCLE_OPACITY 0.6f

#define FLASH_START_POSITION  10.f, 0.f
#define SWITCH_CAMERA_START_POSITION 260.f, 5.f
#define CAMERA_BUTTON_Y_OFFSET 20.f

#pragma mark Preview

#define PUBLISH_BUTTON_XOFFSET 20.f
#define PUBLISH_BUTTON_YOFFSET 20.f
#define PUBLISH_BUTTON_SIZE 75.f

#pragma mark Pull Bar

#define PULLBAR_BUTTON_XOFFSET 20.f
#define PULLBAR_BUTTON_YOFFSET 15.f
#define PULLBAR_PULLDOWN_ICON_WIDTH 60.f
#define PULLBAR_HEIGHT_MENU_MODE 60.f
#define PULLBAR_HEIGHT_PULLDOWN_MODE 30.f


#pragma mark Verbatm Image Scroll View
#define VIEW_WALL_OFFSET 20

#pragma mark - Content Dev VC -

#define MIN_PINCHVIEW_SIZE 100
//distance two fingers must travel for the horizontal pinch to be accepted
#define HORIZONTAL_PINCH_THRESHOLD 100
#define TEXTFIELD_BORDER_WIDTH 0.8f
#define AUTO_SCROLL_OFFSET 10
#define CONTENT_SIZE_OFFSET 20
#define OFFSET_BELOW_ARTICLE_TITLE 30
//distance between elements on the page
#define ELEMENT_OFFSET_DISTANCE 20
#define CURSOR_BASE_GAP 10
#define PINCH_DISTANCE_FOR_ANIMATION 100
//the gap between the bottom of the screen and the cursor
#define CENTERING_OFFSET_FOR_TEXT_VIEW 30
//if the image is up- you can scroll up and have it turn to circles. This gives that scrollup distance
#define SCROLLDISTANCE_FOR_PINCHVIEW_RETURN 200

#pragma mark Media Select Tile

#define MEDIA_TILE_SELECTOR_HEIGHT 100.f
#define ADD_MEDIA_BUTTON_OFFSET 5

#pragma mark - Feed -

#define ARTICLE_IN_FEED_BUTTON_HEIGHT 50
#define FEED_TOP_OFFSET 30
#define FEED_TITLE_LIST_OFFSET 30

#pragma mark - AVES -

#pragma mark Text

#define TEXT_OVER_AVE_TOP_OFFSET 80.f
#define TEXT_OVER_AVE_STARTING_HEIGHT 100.f
#define TEXT_OVER_AVE_PULLBAR_HEIGHT 40.f
#define TEXT_OVER_AVE_ANIMATION_THRESHOLD 30.f
#define TEXT_OVER_AVE_BORDER 30.f

#endif
