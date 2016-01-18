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
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
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
        Logger.getLogger(POVEndpoint.class.getName());

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

    @ApiMethod(path="/insertPost", httpMethod = "PUT")
    public final void insertPost() {

    }

    @ApiMethod(path="/getRecentPosts", httpMethod = "GET")
    public final List<Post> getRecentPosts(@Named("count") final int count) {
        List<Post> posts = new ArrayList<Post>();
        try {
            String url = getCloudSQLURL();
            if (url == null) return null;
            Connection connection = DriverManager.getConnection(url);
            try {
                String statement = "SELECT * FROM Post ORDER BY date_created_ts ASC;";
                PreparedStatement sqlStmt = connection.prepareStatement(statement);
                ResultSet rs = sqlStmt.executeQuery();
                while (rs.next()) {
                    Long postId = rs.getLong("post_id");
                    Long channelId = rs.getLong("channel_id");
                    Long sharedFromPostId = rs.getLong("shared_from_post_id");
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
        return null;
    }

    @ApiMethod(path="/getPagesInPost", httpMethod = "GET")
    public final List<Page> getPagesInPost(@Named("post_id") final Long postId) {
        return null;
    }

    @ApiMethod(path="/getImagesInPage", httpMethod = "GET")
    public final List<Image> getImagesInPage(@Named("page_id") final Long pageId) {
        return null;
    }

    @ApiMethod(path="/getVideosInPage", httpMethod = "GET")
    public final List<Video> getVideosInPage(@Named("page_id") final Long pageId) {
        return null;
    }

    @ApiMethod(path="/getUsersWhoLikePost", httpMethod = "GET")
    public final List<VerbatmUser> getUsersWhoLikePost(@Named("post_id") final Long postId) {
        return null;
    }

    @ApiMethod(path="/getUsersWhoSharedPost", httpMethod = "GET")
    public final List<VerbatmUser> getUsersWhoSharedPost(@Named("post_id") final Long postId) {
        return null;
    }

    /**
     * Updates Like table to say that user liked or unliked post
     * @param userId
     * @param postId
     * @param liked
     */
    @ApiMethod(path="/userLikedPost", httpMethod = "PUT")
    public final void userLikedPost(@Named("user_id") final Long userId,
                                    @Named("post_id") final Long postId,
                                    @Named("liked") Boolean liked) {

    }

    /**
     * Updates Share table
     * @param userId
     * @param postId
     * @param shareType Facebook, Twitter, or channel name if reblogged
     */
    @ApiMethod(path="/userSharedPost", httpMethod = "PUT")
    public final void userSharedPost(@Named("user_id") final Long userId,
                                     @Named("post_id") final Long postId,
                                     @Named("share_type") final String shareType) {

    }

}
