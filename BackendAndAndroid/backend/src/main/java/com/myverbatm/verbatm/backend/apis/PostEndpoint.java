package com.myverbatm.verbatm.backend.apis;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiClass;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.ApiNamespace;
import com.google.api.server.spi.config.Named;
import com.google.appengine.api.utils.SystemProperty;
import com.myverbatm.verbatm.backend.Constants;
import com.myverbatm.verbatm.backend.models.Image;
import com.myverbatm.verbatm.backend.models.Page;
import com.myverbatm.verbatm.backend.models.Post;
import com.myverbatm.verbatm.backend.models.VerbatmUser;
import com.myverbatm.verbatm.backend.models.Video;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Exposes REST API
 */
@Api(name = "verbatmApp",
    version = "v1",
    namespace = @ApiNamespace(
        ownerDomain = Constants.API_OWNER,
        ownerName = Constants.API_OWNER,
        packagePath = Constants.API_PACKAGE_PATH
    )
)

@ApiClass(resource = "post",
    clientIds = {
        Constants.ANDROID_CLIENT_ID,
        Constants.IOS_CLIENT_ID,
        Constants.WEB_CLIENT_ID},
    audiences = {Constants.AUDIENCE_ID}
)

public class PostEndpoint {

    /**
     * Log output.
     */
    private static final Logger log =
        Logger.getLogger(PostEndpoint.class.getName());

    public PostEndpoint() {
    }

    private String getCloudSQLURL() {
        String url = null;
        try {
            if (SystemProperty.environment.value() == SystemProperty.Environment.Value.Production) {
                Class.forName("com.mysql.jdbc.GoogleDriver");
                url = "jdbc:google:mysql://"
                    + Constants.PROJECT_ID + ":"
                    + Constants.CLOUD_SQL_INSTANCE_NAME + "/"
                    + Constants.DATABASE_NAME + "?user=root";
            } else {
                // Local MySQL instance to use during development.
                Class.forName("com.mysql.jdbc.Driver");
                url = "jdbc:mysql://"
                    + Constants.LOCAL_MYSQL_INSTANCE_IP + "/"
                    + Constants.DATABASE_NAME + "?user=root";
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return url;
    }

    /**
     * Inserts post. Needs to insert all pages after inserting post in one atomic transaction.
     * Needs to insert all videos and images for a page after inserting page in same transaction
     * so that a page never exists with no content and a post never exists with no pages.
     * @param post
     */
    @ApiMethod(path="/insertPost", httpMethod = "PUT")
    public final Post insertPost(Post post) {
        Connection connection = null;
        PreparedStatement insertPost = null;
        PreparedStatement insertPages = null;
        PreparedStatement insertImages = null;
        PreparedStatement insertVideos = null;

        String insertPostStatement =
            "INSERT INTO Posts (channel_id, shared_from_post_id) " +
                "VALUES (?, ?)";

        String insertPageStatement =
            "INSERT INTO Pages (post_id, page_num) " +
                "VALUES (?, ?)";

        String insertImageStatement =
            "INSERT INTO Images (url, page_id, text, text_pos, num_in_page) " +
                "VALUES (?, ?, ?, ?, ?)";

        String insertVideoStatement =
            "INSERT INTO Videos (blob_key, page_id, text, text_pos, num_in_page) " +
                "VALUES (?, ?, ?, ?, ?)";

        try {
            String url = getCloudSQLURL();
            if (url == null) return null;
            connection = DriverManager.getConnection(url);
            try {
                // NEEDS TO INSERT POST BEFORE PAGES BEFORE VIDEOS/IMAGES,
                // BUT POST SHOULD NOT EXIST IN DATABASE UNLESS ALL PAGES, IMAGES, AND VIDEOS
                // ARE INSERTED
                connection.setAutoCommit(false);

                insertPost = connection.prepareStatement(insertPostStatement, Statement.RETURN_GENERATED_KEYS);
                insertPages = connection.prepareStatement(insertPageStatement, Statement.RETURN_GENERATED_KEYS);
                insertImages = connection.prepareStatement(insertImageStatement);
                insertVideos = connection.prepareStatement(insertVideoStatement);

                insertPost.setInt(1, post.getChannelId());
                insertPost.setInt(2, post.getSharedFromPostId());
                insertPost.executeUpdate();
                ResultSet keys = insertPost.getGeneratedKeys();
                keys.next();
                Integer postId = keys.getInt(1);

                //mapping from page num to page id in sql
                Map<Integer, Integer> pageIds = new HashMap<Integer, Integer>();
                for (Page page : post.getPages().pages) {
                    insertPages.setInt(1, postId);
                    insertPages.setInt(2, page.getPageNumberInPost());
                    insertPages.executeUpdate();
                    keys = insertPages.getGeneratedKeys();
                    keys.next();
                    Integer pageId = keys.getInt(1);
                    pageIds.put(page.getPageNumberInPost(), pageId);
                }

                for (Image image : post.getImages().images) {
                    //(url, page_id, text, text_pos, num_in_page)
                    insertImages.setString(1, image.getServingUrl());
                    // set page id
                    insertImages.setInt(2, pageIds.get(image.getPageNum()));
                    insertImages.setString(3, image.getText());
                    insertImages.setFloat(4, image.getTextYPosition());
                    insertImages.setInt(5, image.getIndexInPage());
                    insertImages.executeUpdate();
                }

                for (Video video : post.getVideos().videos) {
                    //(blob_key, page_id, text, text_pos, num_in_page)
                    insertVideos.setString(1, video.getBlobKeyString());
                    // set page id
                    insertVideos.setInt(2, pageIds.get(video.getPageNum()));
                    insertVideos.setString(3, video.getText());
                    insertVideos.setFloat(4, video.getTextYPosition());
                    insertVideos.setInt(5, video.getIndexInPage());
                    insertVideos.executeUpdate();
                }

                connection.commit();
            } finally {
                if (insertImages != null) {
                    insertImages.close();
                }
                if (insertVideos != null) {
                    insertVideos.close();
                }
                if (insertPages != null) {
                    insertPages.close();
                }
                if (insertPost != null) {
                    insertPost.close();
                }
                connection.setAutoCommit(true);
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            if (connection != null) {
                try {
                    System.err.print("Transaction is being rolled back");
                    connection.rollback();
                } catch(SQLException sqlExc) {
                    sqlExc.printStackTrace();
                }
            }
        }
        return post;
    }

    @ApiMethod(path="/getRecentPosts", httpMethod = "GET")
    public final List<Post> getRecentPosts(@Named("count") final int count) {
        List<Post> posts = new ArrayList<Post>();
        try {
            String url = getCloudSQLURL();
            if (url == null) return null;
            Connection connection = DriverManager.getConnection(url);
            try {
                String statement = "SELECT * FROM Posts ORDER BY date_created_ts ASC;";
                PreparedStatement sqlStmt = connection.prepareStatement(statement);
                ResultSet rs = sqlStmt.executeQuery();
                while (rs.next()) {
                    Integer postId = rs.getInt("post_id");
                    Integer channelId = rs.getInt("channel_id");
                    Integer sharedFromPostId = rs.getInt("shared_from_post_id");
                    Timestamp createdStamp = rs.getTimestamp("date_created_ts");
                    Post post = new Post(postId, channelId, sharedFromPostId, createdStamp);
                    posts.add(post);
                }
            } finally {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    @ApiMethod(path="/getPostsInChannel", httpMethod = "GET")
    public final List<Post> getPostsInChannel(@Named("channel_id") final int channelId) {
        List<Post> posts = new ArrayList<Post>();
        try {
            String url = getCloudSQLURL();
            if (url == null) return null;
            Connection connection = DriverManager.getConnection(url);
            try {
                String statement = "SELECT * FROM Posts WHERE channel_id = ? ORDER BY date_created_ts ASC;";
                PreparedStatement sqlStmt = connection.prepareStatement(statement);
                sqlStmt.setInt(1, channelId);
                ResultSet rs = sqlStmt.executeQuery();
                while (rs.next()) {
                    Integer postId = rs.getInt("post_id");
                    Integer postChannelId = rs.getInt("channel_id");
                    Integer sharedFromPostId = rs.getInt("shared_from_post_id");
                    Timestamp createdStamp = rs.getTimestamp("date_created_ts");
                    Post post = new Post(postId, postChannelId, sharedFromPostId, createdStamp);
                    posts.add(post);
                }
            } finally {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    @ApiMethod(path="/getPagesInPost", httpMethod = "GET")
    public final List<Page> getPagesInPost(@Named("post_id") final Integer postId) {
        return null;
    }

    @ApiMethod(path="/getImagesInPage", httpMethod = "GET")
    public final List<Image> getImagesInPage(@Named("page_id") final Integer pageId) {
        return null;
    }

    @ApiMethod(path="/getVideosInPage", httpMethod = "GET")
    public final List<Video> getVideosInPage(@Named("page_id") final Integer pageId) {
        return null;
    }

    @ApiMethod(path="/getUsersWhoLikePost", httpMethod = "GET")
    public final List<VerbatmUser> getUsersWhoLikePost(@Named("post_id") final Integer postId) {
        return null;
    }

    @ApiMethod(path="/getUsersWhoSharedPost", httpMethod = "GET")
    public final List<VerbatmUser> getUsersWhoSharedPost(@Named("post_id") final Integer postId) {
        return null;
    }

    /**
     * Updates Like table to say that user liked or unliked post
     * @param userId
     * @param postId
     * @param liked
     */
    @ApiMethod(path="/userLikedPost", httpMethod = "PUT")
    public final void userLikedPost(@Named("user_id") final Integer userId,
                                    @Named("post_id") final Integer postId,
                                    @Named("liked") Boolean liked) {

    }

    /**
     * Updates Share table
     * @param userId
     * @param postId
     * @param shareType Facebook, Twitter, or channel name if reblogged
     */
    @ApiMethod(path="/userSharedPost", httpMethod = "PUT")
    public final void userSharedPost(@Named("user_id") final Integer userId,
                                     @Named("post_id") final Integer postId,
                                     @Named("share_type") final String shareType) {

    }

}
