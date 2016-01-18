package com.myverbatm.verbatm.backend.apis;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiClass;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.ApiNamespace;
import com.google.appengine.api.utils.SystemProperty;
import com.myverbatm.verbatm.backend.Constants;
import com.myverbatm.verbatm.backend.models.Channel;
import com.myverbatm.verbatm.backend.models.Post;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
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

@ApiClass(resource = "channel",
    clientIds = {
        Constants.ANDROID_CLIENT_ID,
        Constants.IOS_CLIENT_ID,
        Constants.WEB_CLIENT_ID},
    audiences = {Constants.AUDIENCE_ID}
)
public class ChannelEndpoint {

    /**
     * Log output.
     */
    private static final Logger log =
        Logger.getLogger(ChannelEndpoint.class.getName());

    public ChannelEndpoint() {
    }

    /**
     * Inserts a new channel
     * @param channel
     * @return
     */
    @ApiMethod(path="/insertChannel", httpMethod = "PUT")
    public final Channel insertChannel (Channel channel) {

        String insertChannelStatement =
            "INSERT INTO Channels (channel_name, creator_user_id) " +
                "VALUES (?, ?)";

        try {
            String url = PostEndpoint.getCloudSQLURL();
            if (url == null) return null;
            Connection connection = DriverManager.getConnection(url);
            try {
                PreparedStatement insertChannel = connection.prepareStatement(insertChannelStatement, Statement.RETURN_GENERATED_KEYS);
                insertChannel.setString(1, channel.getName());
                insertChannel.setInt(2, channel.getCreatorUserId());
                insertChannel.executeUpdate();
                ResultSet keys = insertChannel.getGeneratedKeys();
                keys.next();
                Integer channelId = keys.getInt(1);
                channel.setId(channelId);

            } finally {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return channel;
    }

}
